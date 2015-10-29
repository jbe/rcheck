module RCheck
  module ClassMethods
    extend Forwardable
    
    def all() RCheck::ROOT_SUITE end

    def_delegators(:all, *%i(suite [] report! severity))
    def_delegators(Colors, *%i(show_legend))
    def_delegators(Invocation, *%i(invocation invoke! seed))

    def version
      "RCheck #{VERSION} @ Ruby #{RUBY_VERSION}"
    end

    def config?(param)
      !! Invocation.find(:_base).read(param)
    end

    def which
      File.expand_path('../../..', __FILE__)
    end
  end

  extend ClassMethods
end
