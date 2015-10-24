require 'rcheck'

module RCheck
  class CLI

    class Parser
      def initialize(argv)
        @argv        = argv
        @config      = {}
        @invocations = []
        parse
      end

      attr_reader(*%i(argv config invocations))

      def usage?()    @usage    end
      def version?()  @version  end

      def parse
        @argv.each do |arg|
          case arg
          when *%w(--help --usage help usage -h) then @usage   = true
          when *%w(--version version -v)         then @version = true
          when /^--(.+)/                         then remember arg[2..-1]
          else interpret(arg)
          end
        end
        check_missing_value_error
      end

      def remember(key)
        check_missing_value_error
        unless RCheck.config?(key.to_sym)
          puts "unrecognized parameter: --#{key}"
          exit 1
        end
        @name = key.to_sym
      end

      def interpret(word)
        if @name
          @config[@name] = word.to_sym
          @name          = nil
        else
          @invocations << word.to_sym
        end
      end

      def check_missing_value_error
        return unless @name
        puts "No value provided for --#{@name}!"
        exit 1
      end
    end

    def self.invoke!(argv)
      cmd = Parser.new(argv)
      show_usage    if cmd.usage?
      show_version  if cmd.version?
      exit 0 if cmd.usage? or cmd.version?
      safe_invoke! cmd
    end

    def self.safe_invoke!(cmd)
      RCheck.invoke!(*cmd.invocations, cmd.config)
    rescue Errors::Base => e
     puts e.inspect
     exit 1
    end

    def self.show_usage
      puts "usage: rcheck [INVOCATIONS..] [OPTIONS..]"
      puts "       rcheck help    (-h)"
      puts "       rcheck version (-v)"
      puts
      puts "Examples:"
      puts
      puts "       rcheck"
      puts "       rcheck --path tests/thing.rb"
      puts "       rcheck list"
      puts "       rcheck tree"
      puts "       rcheck silent html --seed 1234"
      puts
      puts "Available invocations"
      RCheck.invocations.each do |inv|
        puts "%10s -- #{inv.description}" % [inv.name]
      end
    end

    def self.show_version
      puts RCheck.version
    end
  end
end
