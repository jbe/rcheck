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

    def cwd_commit_hash
      path = File.expand_path File.join(*%w(.git refs heads master))
      File.read(path).chomp if File.file? path
    end

    def debug_headers
      [ version,
        "#{Date.today.to_s} seed: #{RCheck.seed}",
        "#{RUBY_PLATFORM}",
          cwd_commit_hash
        ].flatten.compact
    end

    def config?(param)
      !! Invocation.find(:_base).read(param)
    end
  end

  extend ClassMethods
end
