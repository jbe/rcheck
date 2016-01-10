

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
      attr_reader :result

      def inspect
        "#<#{self.class.name}: #{status}>"
      end
    end

    class Pending < Abstract
      def initialize(desc=nil)
        @result = Result.new(
          introspection:  desc,
          status:         :pending,
          location:       caller(3))
      end
    end

    class AbstractAssert < Abstract
      def initialize(left, op=nil, *right)
        @left   = left
        @op     = op
        @right  = right
        @truth = (@right.empty? && @op.nil?) ?
          @left : @left.send(@op, *@right)

        @result = Result.new(
          status:         !!@truth != !!@refute ? :pass : :fail,
          location:       caller(4),
          introspection:  introspection)
      end

      private
      def introspection
        args = @right.map(&:inspect).join(', ')
        @left.inspect + case @op
        when *%i(== === < > <= >= ~= <=>) then " #{@op} #{args}"
        when :[]  then "[#{args}]"
        when :[]=
          "[#{@right.first.inspect}] = "\
            "#{@right[1..-1].map(&:inspect).join(', ')}"
        when nil then ''
        else ".#{@op.to_s} #{args}"
        end + " # #{@truth.inspect}"
        # TODO: only show comment if different from introspection
      end
    end

    class Assert < AbstractAssert
      # TODO: use self.is_a? instead
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
      def initialize(expected, msg=nil, &blk)
        @expected = expected
        @expected_msg = msg
        @status = :fail
        begin
          blk.call
        rescue Exception => e
          @raised = e
          if @expected && e.is_a?(@expected) && (msg.nil? || e.message == msg)
            @status = :pass
          end
        end
        @status = :pass if @expected.nil? and @raised.nil?

        @result = Result.new(
          status:         @status,
          location:       caller(3),
          introspection:  @raised ? @raised.inspect : 'no errors',
          backtrace:      @status == :fail ? @raised.backtrace : nil)
      end
    end
  end
end
