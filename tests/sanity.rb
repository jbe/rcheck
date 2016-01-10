RCheck :sanity do

  suite :axioms do
    suite :foundation do
      assert true
      debug "truth asserts"
      refute true
      debug "lie refutes"
      assert_safe { sleep 0.000001 }
      debug "sleeping is safe"
      assert_raises(RuntimeError, 'error') { raise 'error' }
      debug "assert_raises catches runtime error"
    end

    suite :equality do
      assert 1, :equal?, 1
      assert 1, :eql?,   1
      assert 1, :==,     1
      assert 1, :===,    1
    end

    suite :comparison do
      assert 2, :>,      1
      assert 1, :>=,     1
      assert 1, :<,      2
      assert 1, :<=,     1
      assert 1, :<=>,    2
    end

    suite :matching do
      assert 0..10, :===, 5
      assert(/hm/, :===, "hmmmmm")
    end

    suite :brackets do
      assert [true, false], :[], 0
      refute [true, false], :[], 1
      assert [], :[]=, 0, true
    end

    suite :methods do
      assert Object, :respond_to?, :new
      assert Object.new, :instance_of?, Object
      assert Class, :is_a?, Class
    end

    suite :within_delta do
      assert 0.2, :>, 1.0 - 1.0
      assert 0.1, :>, 100000000.0 - 100000000.0
    end

    suite :scope do
      def helper_method() :helper_method end
      helper_var    =     :helper_var
      HELPER_CONST  =     :helper_const

      suite :upwards do
        assert helper_method,     :==, :helper_method
        assert helper_var,        :==, :helper_var
        assert HELPER_CONST,      :==, :helper_const
      end

      suite :_unreachable do
        def descendant_method() :helper_method end
        descendant_var    =     :helper_var
      end

      suite :downwards do
        assert_raises(NameError) { descendant_method }
        assert_raises(NameError) { descendant_var }
      end
    end

    suite :generics do
      def example_law(suite, *args)
        suite.assert(*args)
      end

      suite :child do
        example_law self, true
      end

      def assert_custom(left, *rest)
        assert(left, *rest)
        val = nil
        assert_safe do
          val = rest.any? ? left.send(*rest) : left
        end
        assert val
        refute !val
        true
      end

      assert_custom true
      assert_custom :symbol
      assert_custom Class
      assert_custom true, :==, true
      assert_custom Class, :is_a?, Class
      assert_custom nil, :nil?
      assert_custom assert_custom(true)
    end
  end

  # failures
  # assert false
  # debug "it was false!"
  # refute true, :==, true
  # debug "it really was"
  # raise 'bah'
  #
  # assert_raises(RuntimeError, "yo") { raise 'bug' }
  # assert_safe { raise("finger") }
end
