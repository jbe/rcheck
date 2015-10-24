module RCheck
  class Invocation
    T_LABEL     = :current_rcheck_config
    COLLECTION  = {}

    def self.active=(inv)       Thread.current[T_LABEL] = inv end
    def self.active?()          !!Thread.current[T_LABEL]     end
    def self.find(name)         COLLECTION[name]              end
    def self.remember(inv)      COLLECTION[inv.name] = inv    end
    def self.invocation(*args)  remember new(*args)           end

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
      new(nil, '(anonymous)', *(args << :_base).reverse).
        invoke!.exit_with_code!
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
    def suite()   RCheck[self[:suite]] end

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
      self[:filter].inject(lines) do |memo, bfilter|
        bfilter.filter(memo)
      end.map do |str|
        Backtrace::Line.new str
      end
    end

    private

    def run!
      Colors.cputs :quiet, RCheck.debug_headers
      puts
      require_all self[:files]
      2.times { puts }
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

    def require_all(*globs)
      globs.map do |glob|
        Dir[glob].map do |file|
          rel = File.join File.dirname(file), File.basename(file, '.*')
          File.expand_path rel
        end
      end.flatten.shuffle(random: Random.new(self[:seed])).
        each { |path| require path }
    end
  end
end
