RCheck.suite 'RCheck/sanity'.split('/') do
  suite 'axioms' do
    assert_safe { sleep 0.000001 }

    assert_raises(RuntimeError, 'error') do
      raise 'error'
    end

    assert true
    refute false

    assert 1, :equal?, 1
    assert 1, :eql?,   1
    assert 1, :==,     1
    assert 1, :===,    1

    assert 2, :>,      1
    assert 1, :>=,     1
    assert 1, :<,      2
    assert 1, :<=,     1

    assert Object, :respond_to?, :new
    assert Object.new, :instance_of?, Object
    assert Object.new, :kind_of?, BasicObject

    assert 0..10, :===, 5
    assert(/hm/, :===, "hmmmmm")

    assert 0.2, :>, 1.0 - 1.0
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
end



# RCheck.suite 'RCheck/assertions' do
# end

 RCheck.suite 'RCheck' do
   suite('VERSION'          ) { pending }
   suite('Errors'           ) { pending }
#   suite('Colors'           ) { pending }
#   suite('Assertions'       ) { pending }
#   suite('Debugging'        ) { pending }
#   suite('suite'            ) { pending }
#   suite('dsl'              ) { pending }
#   suite('backtrace_filters') { pending }
#   suite('backtrace'        ) { pending }
#   suite('progress_printers') { pending }
#   suite('report_printers'  ) { pending }
 end
