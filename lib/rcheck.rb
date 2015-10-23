
require 'rcheck/version'
require 'rcheck/errors'
require 'rcheck/colors'
require 'rcheck/assertions'
require 'rcheck/debugging'
require 'rcheck/suite'
require 'rcheck/dsl'
require 'rcheck/backtrace_filters'
require 'rcheck/backtrace'
require 'rcheck/progress_printers'
require 'rcheck/report_printers'

module RCheck
  ROOT_SUITE = Suite.new(nil, nil)

  class << self
    def all() RCheck::ROOT_SUITE end
    extend Forwardable
    def_delegators(:all, *%i(suite [] report!))
    def_delegators(:'RCheck::Colors', *%i(show_legend))

    attr_accessor :seed

    def runner=(runner)
      Thread.current[:current_rcheck_runner] = runner
    end

    def runner()
      Thread.current[:current_rcheck_runner]
    end

    def debug_headers
      [ "RCheck #{RCheck::VERSION} @ Ruby #{RUBY_VERSION}",
        "#{Date.today.to_s} seed: #{seed}",
        "#{RUBY_PLATFORM}"
        ]
    end
  end

  class Runner
    def initialize(conf={})
      @conf = process_conf(RCheck::DEFAULTS.merge conf)
    end

    extend Forwardable
    def_delegators(:@conf, *%i([]))

    def run(*globs)
      old_runner = RCheck.runner
      RCheck.runner = self
      run_tests Array(globs)
      RCheck.runner = old_runner
    end

    def parse_backtrace(lines)
      self[:backtrace_filters].inject(lines) do |memo, bfilter|
        bfilter.filter(memo)
      end.map do |str|
        Backtrace::Line.new str
      end
    end


    private

    def run_tests(globs)
      Colors.cputs :quiet, RCheck.debug_headers
      puts
      require_all(*globs)
      puts
      RCheck.report!
    end

    def require_all(*globs)
      globs.map do |glob|
        Dir[glob].map do |file|
          rel = File.join File.dirname(file), File.basename(file, '.*')
          File.expand_path rel
        end
      end.flatten.each { |path| require path }
    end

    # helper used to parse configuration values
    # like the ones below
    def to_instance(scope, *list)
      list.map do |item|
        case item
        when Class  then item.new
        when Symbol then scope.const_get(item).new
        else item
        end
      end
    end

    def process_conf(conf)
      conf.keys.each do |name|
        val = case name
        when :colors then parse_theme(conf[name])
        when :progress_printers, :report_printers, :backtrace_filters
          kls = RCheck.const_get(name.to_s.split('_').map(&:capitalize).join.to_sym)
          to_instance(kls, *conf[name])
        else nil
        end
        conf[name] = val unless val.nil?
      end
      conf
    end

    def parse_theme(theme)
      return theme if theme.is_a?(Hash)
      name = :"#{theme.upcase}"
      if Colors::Themes.const_defined?(name)
        Colors::Themes.const_get(name)
      else
        raise "Invalid color theme: #{theme.inspect}"
      end
    end
  end

  self.seed = rand(10000)

  DEFAULTS = {
    progress_printers:  %i(ProgressBar),
    report_printers:    %i(ExpandedFailTree RedList Numbers),
    colors:             :default,
    backtrace_filters:  :Default
  }
end
