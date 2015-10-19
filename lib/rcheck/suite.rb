module RCheck
  class Suite
    include Assertions::SuiteMethods
    include Debugging::SuiteMethods

    def initialize(parent)
      @parent     = parent
      @scope      = DSL::Scope.new self
      @suites     = {}
      @debuggers  = []
      @assertions = []
    end

    attr_reader(*%i(parent scope assertions debuggers suites))

    def [](*names)
      return self if names.empty?
      names = names.map do |n|
        n.is_a?(String) ? n.split('/') : n
      end.flatten
      part = @suites[names.pop.to_s]
      part ? part[*names] : part
    end

    def suite(*names, &blk)
      if names.any?
        self[*names] ||= Suite.new(self)
        self[*names].suite(&blk)
      else
        @scope.instance_eval(&blk)
      end
    end

    def report!(*printers)
      printers = RCheck.report_printers unless printers.any?
      printers.each { |p| p.report self }
    end

    private

    def []=(name, suite)
      @suites[name.to_s] = suite
    end
  end
end
