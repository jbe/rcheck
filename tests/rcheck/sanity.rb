RCheck.suite 'RCheck/sanity' do

  suite 'axiomatic' do
    suite :foundation do
      assert true
      refute false
      assert_safe { sleep 0.000001 }
      assert_raises(RuntimeError, 'error') { raise 'error' }
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
    end

    suite :methods do
      assert Object, :respond_to?, :new
      assert Object.new, :instance_of?, Object
      assert Object.new, :kind_of?, BasicObject
    end

    suite :matching do
      assert 0..10, :===, 5
      assert(/hm/, :===, "hmmmmm")
    end

    suite :within_delta do
      assert 0.2, :>, 1.0 - 1.0
      assert 0.1, :>, 100000000.0 - 100000000.0
    end

    suite 'scoped_access' do
      def helper_method() :helper_method end
      helper_var    =     :helper_var
      HELPER_CONST  =     :helper_const

      suite 'descendant helpers' do
        def descendant_method() :helper_method end
        descendant_var    =     :helper_var
        DESCENDANT_CONST  =     :helper_const
      end

      suite 'reachable' do
        assert helper_method == :helper_method
        assert helper_var    == :helper_var
        assert HELPER_CONST  == :helper_const
        assert DESCENDANT_CONST == :helper_const
      end

      suite 'unreachable' do
        assert_raises(NameError) { descendant_method }
        assert_raises(NameError) { descendant_var }
      end
    end

    suite :generics do
      def sample_law(suite, *args)
        suite.assert(*args)
      end

      suite :child do
        sample_law self, true
      end

      def assert_obeys_logic(left, *rest)
        assert(left, *rest)
        val = nil
        assert_safe do
          val = rest.any? ? left.send(*rest) : left
        end
        assert val
        refute !val
        true
      end

      assert_obeys_logic true
      assert_obeys_logic :symbol
      assert_obeys_logic Class
      assert_obeys_logic true, :==, true
      assert_obeys_logic Class, :is_a?, Class
      assert_obeys_logic nil, :nil?
      assert_obeys_logic assert_obeys_logic(true)
    end
  end

  suite :meta do
    suite :equal_output do
      cli = File.expand_path File.join(*%w(bin rcheck))
      # use env variable to stop fork bomb?
      # assert `ruby #{cli} --suite RCheck/sanity/axioms` == `rake test:sanity:axioms`
    end
  end

  # failures
  # assert false
  # refute true
  #
  # assert_raises(RuntimeError) { }
  # assert_safe { raise("finger") }

end
