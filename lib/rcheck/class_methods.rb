module RCheck
  module ClassMethods
    extend Forwardable
    
    def root() RCheck::ROOT_SUITE end

    def_delegators(:root, *%i(suite [] severity))
    def_delegators(Command, *%i(define invoke!))

    def version
      "RCheck #{VERSION} @ Ruby #{RUBY_VERSION}"
    end

    def which
      File.expand_path('../../..', __FILE__)
    end
  end
end
