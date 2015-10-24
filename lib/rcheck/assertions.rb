

module RCheck
  module Assertions
    module SuiteMethods

      def assert(*args)
        verify_not_done!
        @assertions << Assert.new(*args)
      end

      def refute(*args)
        verify_not_done!
        @assertions << Refute.new(*args)
      end

      def assert_raises(*args, &blk)
        verify_not_done!
        @assertions << Raises.new(*args, &blk)
      end

      def assert_safe(&blk)
        verify_not_done!
        @assertions << Raises.new(nil, &blk)
      end

      def pending(*args)
        verify_not_done!
        @assertions << Pending.new(*args)
      end
    end

    class Abstract
      attr_reader(*%i(status backtrace))

      def initialize(status, trace)
        @status     = status
        @backtrace  = Invocation.parse_backtrace trace
        ProgressPrinters.track_progress! self
      end
    end

    class Pending < Abstract
      attr_reader(*%i(reason))
      def initialize(reason=nil)
        @reason = reason
        super :pending, caller(3)
      end
      def message
        [@reason].compact
      end
    end

    class AbstractAssert < Abstract
      attr_reader(*%i(name truth left op right))
      def initialize(left, op=nil, *right)
        @left   = left
        @op     = op
        @right  = right
        @result = if right.empty? && op.nil?
          left
        else
          left.send(op, *right)
        end
        super !!@result != !!@refute ? :pass : :fail, caller(4)
      end

      def message
        [left, op, (right if right.any?)].compact.map(&:inspect)
      end
    end

    class Assert < AbstractAssert
      def initialize(*args)
        @refute = false
        super
      end
    end

    class Refute < AbstractAssert
      def initialize(*args)
        @refute = true
        super
      end
    end

    class Raises < Abstract
      attr_reader(*%i(expected expected_msg raised))
      def initialize(expected, msg=nil, &blk)
        @expected = expected
        @expected_msg = msg
        @status = :fail
        begin
          blk.call
        rescue Exception => e
          @raised = e
          if @expected && e.is_a?(expected) && (msg.nil? || e.message == msg)
            @status = :pass
          end
        end
        @status = :pass if @expected.nil? and @raised.nil?
        super @status, caller(3)
      end

      def message
        [ "expected: #{[@expected || 'no errors', @expected_msg].compact.map(&:inspect).join(', ')}",
          "got:      #{@raised ? @raised.inspect : 'nothing'}",
          (Invocation.parse_backtrace @raised.backtrace.map(&:to_s) if @raised)].flatten
      end
    end
  end
end
