module RCheck
  module Debugging
    module SuiteMethods
      def debug(*args)
        verify_not_done!
        unless @assertions.any?
          raise Errors::NoAssertions, 'debugger without a preceding assertion'
        end
        @assertions.last.debuggers << Debugger.new(*args)
      end
    end

    class Debugger
      attr_reader :items, :backtrace

      def initialize(*items)
        @items      = items
        @backtrace  = Backtrace.parse caller(3)
      end

      def join
        @items.map do |data|
          data.is_a?(String) ? data : data.inspect
        end.join(' ')
      end

      def location
        @backtrace.first
      end
    end
  end
end
