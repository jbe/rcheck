
module RCheck
  module DSL
    class Scope
      def initialize(suite)
        @__suite__ = suite
      end
      extend Forwardable
      def_delegators(:@__suite__,
        :suite, :assert, :refute, :assert_safe,
        :assert_raises, :debug, :pending)

      def respond_to?(name)
        super || @__suite__.parent && @__suite__.parent.scope.respond_to?(name)
      end

      def method_missing(*args)
        if @__suite__.parent
          @__suite__.parent.scope.send(*args)
        else
          super
        end
      end
    end
  end
end
