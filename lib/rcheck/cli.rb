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
      def help?()     @help     end
      def version?()  @version  end

      def parse
        @argv.each do |arg|
          case arg
          when *%w(--help help -h)               then @help    = true
          when *%w(--usage usage)                then @usage   = true
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
      show_help     if cmd.help?
      show_version  if cmd.version?
      exit 0 if cmd.usage? or cmd.version? or cmd.help?
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
      puts "       rcheck usage"
      puts
      puts "Examples:"
      puts
      puts "       rcheck"
      puts "       rcheck --files tests/thing.rb"
      puts "       rcheck tree"
      #puts "       rcheck silent html --seed 1234"
    end

    def self.show_help
      show_usage
      puts
      puts "Available invocations:"
      puts
      Invocation.collection.each do |inv|
        puts "%10s    #{inv.desc}" % [inv.name]
      end
      puts
      puts "Available parameters and base values:"
      puts
      Invocation.find(:_base).config.each do |key, default|
        puts "%16s    #{default.inspect}" % ["--#{key.to_s}"]
      end
    end

    def self.show_version
      puts RCheck.version
    end
  end
end
