module RCheck
  module Debugging
    module SuiteMethods
      def debug(*args)
        verify_not_done!
        @debuggers << Debugger.new(*args)
      end
    end

    class Debugger
      attr_reader(*%i(items))

      def initialize(*items)
        @items = items
      end

      def join
        @items.map do |data|
          data.is_a?(String) ? data : data.inspect
        end.join(' ')
      end
    end
  end
end
