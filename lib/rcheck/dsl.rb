
module RCheck
  module DSL
    class Scope
      def initialize(suite)
        @__suite__ = suite
      end
      extend Forwardable
      def_delegators(:@__suite__,
                     *%i(suite assert assert_raises debug pending))

      def respond_to?(name)
        super || @__suite__.parent.scope.respond_to?(name)
      end

      def method_missing(*args)
        @__suite__.parent.scope.send(*args)
      end
    end
  end
end
