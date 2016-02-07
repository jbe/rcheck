module RCheck
  class Command
    # Command definition dictionary that stores named definitions
    DEFINITIONS = {}
    # Command definitions not included in listings
    HIDDEN      = []

    class << self
      # Return the currently running RCheck command.
      # RCheck may only be invoked once during the life cycle
      # of the running Ruby interpreter.
      def active
        @active || raise("tried to look up command outside command")
      end

      # Hide a named command definition from listings
      def hide(*args)   HIDDEN.push(*args.flatten)        end
      # Find and return a named command definition
      def find(name)    DEFINITIONS[name]                 end
      # Returns true if a command has been invoked
      def active?()     !!@active                         end

      # Sets the invoked command. Can only be done once.
      def active=(inv)
        @active && raise('already invoked')
        @active = inv
      end

      # Defines a named command
      def define(name, *args)
        DEFINITIONS[name] = new(name, *args)
      end

      # Returns an array of available commands
      def available
        DEFINITIONS.values.reject { |c| HIDDEN.include? c.name }
      end

      # Invokes an RCheck command by expanding and using
      # the given commands and options.
      def invoke!(*args)
        args << :_default if args.none? {|a| a.is_a? Symbol } 
        new(nil, '(main)', *(args.unshift(:_base))).invoke!
      end
    end

    attr_reader :name, :desc, :implied_commands, :config

    def initialize(name, desc, *args)
      @name             = name  # if this is a named command definition
      @desc             = desc  # help text
      @implied_commands = []
      @config           = {}
      @cache            = {}
      expand args
    end

    def suite()
      RCheck[self[:suite]] ||
        raise(Errors::NoSuchSuite, "no suite called #{self[:suite]}")
    end

    def read(param)
      @config[param].tap {|v| return v unless v.nil? }
      @implied_commands.reverse.each do |name|
        inv = self.class.find(name) ||
          raise(Errors::InvocationName,
                "unknown invocation #{name.inspect}")
        inv.read(param).tap {|v| return v unless v.nil? }
      end; nil
    end

    def [](param)
      @cache[param] ||= OptionExpander[param, read(param)]
      if @cache[param].nil?
        raise(Errors::ConfigName,
              "no configuration called #{param.inspect}")
      end; @cache[param] # TODO
    end

    def invoke!
      self.class.active = self
      require_initializers
      dispatch
    end

    def dispatch
      [:pry, :how].each do |option|
        return send option if Conf[option]
      end
      run_tests
    end

    def how
      print 'Command chain: '
      print implied_commands.map(&:inspect).join(', ')
      puts  ' ' + @config.inspect
      puts
      Options.names.each do |name|
        puts "  %15s: #{self[name]}" % [name.to_s]
      end
    end

    def pry
      require 'pry'
      RCheck.binding.pry
    end

    def run_tests
      Colors.cputs :quiet, Array(self[:headers]).map(&:call)
      puts if self[:progress].any?
      require_test_files
      [:progress, :report].each {|v| make_space v }
      suite.report!
      exit [:pass, :pending].include?(suite.severity(:total)) ?
        self[:success_code] : self[:fail_code]
    end

    private

    def make_space(for_what)
      puts if self[for_what].any? && suite.total(:all).any?
    end

    def expand(args)
      args.each do |arg|
        case arg
        when Hash   then @config.merge! arg
        when Symbol then @implied_commands << arg
        else raise Errors::Argument, "unexpected #{arg.inspect}"
        end
      end
    end

    def expand_globs(glob_name, randomizer=nil)
      Array(self[glob_name]).map do |glob|
        Dir[glob].map do |file|
          File.expand_path File.join(
            File.dirname(file), File.basename(file, '.*'))
        end
      end.flatten
    end

    def require_globs(glob_name, randomizer=nil)
      files = expand_globs(glob_name)
      files.shuffle!(random: randomizer) if randomizer
      files.each {|path| require path }
    end

    def require_test_files
      require_globs(:files, Random.new(self[:seed]))
    end

    def require_initializers
      require_globs(:initializers)
    end
  end
end
