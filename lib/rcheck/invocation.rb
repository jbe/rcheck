module RCheck

  # module Invocation
  #   class Params
  #     # []
  #   end
  # end

  class Invocation
    T_LABEL     = :current_rcheck_config
    COLLECTION  = {}

    def self.active=(inv)       Thread.current[T_LABEL] = inv end
    def self.active?()          !!Thread.current[T_LABEL]     end
    def self.find(name)         COLLECTION[name]              end
    def self.remember(inv)      COLLECTION[inv.name] = inv    end
    def self.define(*args)      remember new(*args)           end

    def self.collection()
      c = COLLECTION.values
      c.delete COLLECTION[:_base]
      c.delete COLLECTION[:default]
      c
    end

    # extract to config along with stuff from invocation
    def self.config?(param)
      !! find(:_base).read(param)
    end

    def self.active()
      Thread.current[T_LABEL] ||
        raise("tried to look up invocation outside invocation")
    end

    class << self
      extend Forwardable
      def_delegators(:active, *%i([] parse_backtrace seed))
    end

    def self.invoke!(*args)
      args << :default if args.none? {|a| a.is_a? Symbol } 
      new(nil, '(anonymous)', *(args.unshift(:_base))).
        invoke!.exit_with_code!
    end

    def self.inspect_str(obj)
      self[:inspector].first.inspect_str obj
    end

    attr_reader(*%i(name desc invocations config exit_code))

    def initialize(name, desc, *args)
      @name         = name
      @desc         = desc
      @invocations  = []
      @config       = {}
      @cache        = {}
      parse args
    end

    def seed()    self[:seed] end
    def suite()
      RCheck[self[:suite]] ||
        raise(Errors::NoSuchSuite, "no suite called #{self[:suite]}")
    end

    def read(param)
      return @config[param] if @config.has_key? param
      real_invocations.each do |inv|
        v = inv.read(param)
        return v if v
      end
      nil
    end

    def [](param)
      @cache[param] ||= ConfigExpander[param, read(param)] ||
        raise(Errors::ConfigName, "no configuration called #{param.inspect}")
    end

    def invoke!
      old_inv = self.class.active if self.class.active?
      self.class.active = self
      block_given? ? yield : run!
      self.class.active = old_inv
      self
    end

    def exit_with_code!
      invoke! do
        exit %i(pass pending).include?(suite.severity(:total)) ?
          self[:success_code] : self[:fail_code]
      end
    end

    def parse_backtrace(lines)
      lines.reject do |line|
        self[:filters].any? { |f| f.match(line) } and
          !self[:anti_filters].any? { |f| f.match(line) }
      end.map do |str|
        Backtrace::Line.new str
      end
    end

    private

    def run!
      require_initializers
      Colors.cputs :quiet, Array(self[:headers]).map(&:call)
      puts if self[:progress].any?
      require_test_files
      puts if self[:progress].any? && suite.total(:all).any?
      puts if self[:report].any? && suite.total(:all).any?
      suite.report!
    end

    def parse(args)
      args.each do |arg|
        case arg
        when Hash   then @config.merge! arg
        when Symbol then @invocations << arg
        else raise Errors::Argument, "unexpected #{arg.inspect}"
        end
      end
    end

    def real_invocations
      @invocations.reverse.map do |name|
        self.class.find(name) ||
          raise(Errors::InvocationName, "unknown invocation #{name.inspect}")
      end
    end

    def globs_to_require(globs)
      Array(globs).map do |glob|
        Dir[glob].map do |file|
          rel = File.join File.dirname(file), File.basename(file, '.*')
          File.expand_path rel
        end
      end.flatten
    end

    def require_test_files
      globs_to_require(self[:files]).shuffle(random: Random.new(self[:seed])).
        each { |path| require path }
    end

    def require_initializers
      globs_to_require(self[:initializers]).each do |path|
        require path
      end
    end
  end
end
