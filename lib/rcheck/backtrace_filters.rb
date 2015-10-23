module RCheck
  module BacktraceFilters
    class Default
      DEFAULTS = {
        exclude: (%w(/lib\d*/ruby/ bin/ lib/rcheck) +
          [("org/jruby/" if RUBY_PLATFORM == 'java')].compact).map do |s|
            Regexp.new(s.gsub("/", File::SEPARATOR))
          end,
        include: [Regexp.new(Dir.getwd)]
      }

      attr_accessor(*%i(exclude include))

      attr_reader :config

      def initialize(config={})
        @config = DEFAULTS.merge config
      end

      def filter_gem(gem_name)
        sep = File::SEPARATOR
        @config[:exclude] << /#{sep}#{gem_name}(-[^#{sep}]+)?#{sep}/
      end

      def filter(backtrace)
        backtrace.reject { |line| exclude?(line) }
      end

      def exclude?(line)
        @config[:include].none? { |pattern| line =~ pattern } &&
        @config[:exclude].any?  { |pattern| line =~ pattern }
      end
    end
  end
end
