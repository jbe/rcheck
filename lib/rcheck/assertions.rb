module RCheck
  module Assertions
    module SuiteMethods

      def assert(*args)
        @assertions << Assertions::Truth.new(*args)
      end

      def assert_raises(*args, &blk)
        @assertions << Assertions::Raises.new(*args, &blk)
      end

      def pending(*args)
        @assertions << Assertions::Pending.new(*args)
      end
    end

    class Abstract
      attr_reader(*%i(status test_stack))

      def initialize(status)
        @status = status
        @test_stack = caller(2)
      end

      def track_progress!
        RCheck::ProgressPrinter.track_progress! self
      end
    end

    class Pending < Abstract
      attr_reader(*%i(reason))
      def initialize(reason=nil)
        @reason = reason
        super :pending
        track_progress!
      end
    end

    class Truth < Abstract
      attr_reader(*%i(name truth))
      def initialize(truth, name=nil)
        @name   = name
        @truth  = truth
        super @truth ? :fail : :pass
        track_progress!
      end
    end

    class Raises < Abstract
      attr_reader(*%i(expected raised))
      def initialize(expected, msg=nil, &blk)
        @expected = expected
        @status = :fail
        begin
          blk.call
        rescue Exception => e
          @raised = e
          if e.is_a?(expected) && (msg.nil? || e.message == msg)
            @status = :pass
          end
        end
        super @status
        track_progress!
      end
    end
  end
end
