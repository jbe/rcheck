require 'date'

module RCheck
  module Headers
    class Rcheck
      def call
        [RCheck.version, "#{Date.today.to_s} seed: #{Conf[:seed]}"]
      end
    end

    class Platform
      def call() "#{RUBY_PLATFORM}" end
    end

    class Commit
      def call() [cwd_commit_hash].compact end

      def cwd_commit_hash
        path = File.expand_path File.join(*%w(.git refs heads master))
        File.read(path).chomp if File.file? path
      end
    end
  end
end
