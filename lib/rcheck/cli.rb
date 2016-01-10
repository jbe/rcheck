require 'rcheck'
require 'rcheck/trollop'

module RCheck
  class CLI
    TROLLOP = Trollop::Parser.new do
      banner 'Usage:   rcheck [COMMANDS..] [OPTIONS..]'
      banner "Example: rcheck list --files tests/thing.rb --seed 3276"
      banner ''
      banner "Commands:"
      Command.available.each do |cmd|
        banner "%10s    #{cmd.desc}" % [cmd.name]
      end
      banner ''
      banner 'Options:'
      version VERSION
      Options.defaults.each do |k, v|
        opt k, Options::HELP[k], :default => v
      end
    end

    def initialize(argv)
      parse_commands(argv)
      parse_options(argv)
    end

    def invoke!
      RCheck.invoke!(*@commands, @options)
    rescue Errors::Base => e
      puts e.inspect
      exit 1
    end

    private
    def parse_commands(argv)
      @commands = []
      until argv.empty? || argv.first.start_with?('-')
        @commands << argv.shift
      end
      @commands = @commands.map(&:to_sym)
    end

    def parse_options(argv)
      @options = argv.any? ?
        (Trollop::with_standard_exception_handling TROLLOP do
          TROLLOP.parse(argv) # welcome to the syntax sandwich
        end) : {}
      @options.each_key do |name|
        @options.delete name unless name.to_s.end_with?('_given') ||
                                    @options[:"#{name.to_s}_given"]
      end
      @options.each_key do |name|
        @options.delete name if name.to_s.end_with?('_given')
      end
    end
  end
end
