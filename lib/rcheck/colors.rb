
module RCheck
  module Colors
    ESC = {
      red:     "\e[31m",
      green:   "\e[32m",
      yellow:  "\e[33m",
      blue:    "\e[34m",
      magenta: "\e[35m",
      teal:    "\e[36m",
      grey:    "\x1b[38;5;248m",
      reset:   "\e[0m"
    }
    module Themes
      DEFAULT = {
        pass:     :green,
        fail:     :red,
        error:    :yellow,
        pending:  :teal,
        quiet:    :grey
      }
    end

    module Mixin
      def with_color(status)
        color = RCheck.runner[:colors][status] ||
                raise("invalid status: #{status.inspect}")
        code  = ESC[color] || raise("invalid color #{color.inspect}")
        # TODO: support color codes
        print code if STDOUT.tty?
        yield
        print ESC[:reset] if STDOUT.tty?
      end

      def cprint(status, *strings)
        with_color(status) { print(*strings) }
      end

      def cputs(status, *args)
        with_color(status) { puts(*args) }
      end

      def show_legend
        return unless STDOUT.tty?
        RCheck.colors.each do |key, value|
          print ' '
          cprint key, key
        end
        puts
      end
    end

    extend Mixin
  end
end
