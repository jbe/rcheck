module RCheck
  class Suite
    include Assertions::SuiteMethods
    include Debugging::SuiteMethods

    SYNONYMS = {
      all:          %i(error fail pending pass),
      problematic:  %i(error fail pending),
      critical:     %i(error fail)
    }

    def initialize(parent, name)
      @parent     = parent
      @name       = name
      @scope      = DSL::Scope.new self
      @suites     = {}
      @assertions = []
      @result     = Result.new(
        progress: false, status: :pass, location: [full_name])
    end

    attr_reader(*%i(parent name scope assertions result))

    def inspect
      "#<#{self.class}: #{full_name.inspect}>"
    end

    def suites
      case Conf[:print_order]
      when 'name' then @suites.values.sort_by(&:name)
      when 'run'  then @suites.values
      else raise Errors::ConfigName,
        "unknown suite ordering: #{Conf[:print_order]}"
      end
    end

    alias :children :suites

    def [](*names)
      names = groom_name_chain(names)
      return self if names.empty?
      name  = names.shift.to_s
      @suites[name][*names] if @suites[name]
    end

    def find_or_create(*names)
      names = groom_name_chain(names)
      return self if names.empty?
      name  = names.shift.to_s
      @suites[name] ||= Suite.new(self, name)
      @suites[name].find_or_create(*names)
    end

    def suite(*names, &blk)
      verify_not_done!
      if names.any?
        find_or_create(*names).suite(&blk)
      else
        begin
          @scope.instance_eval(&blk) if blk
        rescue Exception => e
          @exception = e
          @result = Result.new(
            status:         :error,
            introspection:  @exception.inspect,
            backtrace:      @exception.backtrace,
            location:       @exception.backtrace)
        end
        self
      end
    end

    def report!(*printers)
      done!
      printers = Conf[:report] unless printers.any?
      printers.each do |p|
        p.report self
        puts
      end
    end

    def local(*statuses)
      if (statuses.length == 1) && SYNONYMS[statuses.first]
        statuses = SYNONYMS[statuses.first]
      end
      assertions.select { |a| statuses.include? a.result.status } +
        (statuses.include?(:error) && @exception ? [self] : [])
    end

    def total(*statuses)
      @subtree_cache ||= {}
      @subtree_cache[statuses] ||= local(*statuses) +
        suites.map do |child_suite|
          child_suite.total(*statuses)
        end.inject([], :+)
    end

    def subtree(*statuses)
      total(statuses) - local(statuses)
    end

    def counts(scope)
      Hash[%i(error fail pending pass).map do |sym|
        [sym, send(scope, sym).count]
      end]
    end

    def severity(scope)
      %i(error fail pending).each do |severity|
        return severity if send(scope, severity).any?
      end
      :pass
    end

    def name_chain
      @parent.nil? ? [] : @parent.name_chain.push(name)
    end

    def full_name
      name_chain.join('/')
    end

    attr_reader :locked

    def done!
      @locked ||= (suites.each(&:done!); true)
    end

    def verify_not_done!
      if @locked
        raise Errors::SuiteRedefinition, "#{self} cannot be modified"\
          "because it has been marked as done"
      end
    end

    private

    def groom_name_chain(names)
      names = names.flatten.map do |n|
        n.to_s.split('/')
      end.flatten
    end
  end
end
