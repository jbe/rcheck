
RCheck 'RCheck/ClassMethods' do
  suite :version do
    assert RCheck.version, :include?, "Ruby #{RUBY_VERSION}"
    assert RCheck.version, :include?, RCheck::VERSION
  end
  
  suite :which do
    assert File, :directory?, RCheck.which
  end

  suite :root do
    assert RCheck.root, :is_a?, RCheck::Suite
    assert RCheck.root.name, :nil?
    assert RCheck.root.parent, :nil?
    assert RCheck.root, :==, RCheck::ROOT_SUITE
  end

  sample_name = 'samples/waffles'
  sample = RCheck.suite(sample_name) { }

  suite :suite do
    assert RCheck.suite,              :==, RCheck.root
    assert RCheck.suite(sample_name), :==, sample
  end

  suite :[] do
    assert RCheck[],            :==, RCheck.root
    assert RCheck[sample_name], :==, sample
  end

  suite :severity do
    %i(local total subtree).each do |scope|
      assert RCheck.severity(scope), :is_a?, Symbol
    end
  end

  suite :define do
    name = :sample_command
    val = RCheck.define(name, '')
    assert val, :is_a?, RCheck::Command
    assert RCheck::Command.find(name), :==, val
  end

  suite :invoke! do
    # rcheck was probably already invoked using this syntax, so
    # there is no need, nor possible to do it again here.
    assert RCheck, :respond_to?, :invoke!
  end
end
