
RCheck.suite RCheck do
  suite 'suites' do
    suite 'assertions' do
      assert true, 'assert true passes'

      suite 'arithmetic' do
        assert 1 + 1 == 2
        debug 'if this is printed, then one plus one is not two'
      end

      suite 'exceptions' do
        assert_raises(RuntimeError, 'error') do
          raise 'error'
        end
      end
    end

    suite 'helpers and scopes' do
      def helper_method() :helper_method end
      helper_var    =     :helper_var
      HELPER_CONST  =     :helper_const

      suite 'descendant helpers' do
        def descendant_method() :helper_method end
        descendant_var    =     :helper_var
        DESCENDANT_CONST  =     :helper_const
      end

      suite 'ascendant helpers reachable' do
        assert helper_method == :helper_method
        assert helper_var    == :helper_var
        assert HELPER_CONST  == :helper_const
      end

      suite 'descendant helpers unreachable' do
        assert_raises(NameError) { descendant_method }
        assert_raises(NameError) { descendant_var }
        assert_raises(NameError) { DESCENDANT_CONST }
      end
    end

    suite 'API' do
      pending
    end

    suite 'Reporters' do
      pending
    end

  end
end
