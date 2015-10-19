
module RCheck
  module Colors
    ESC = {
      red:     "\e[31m",
      green:   "\e[32m",
      yellow:  "\e[33m",
      blue:    "\e[34m",
      magenta: "\e[35m",
      teal:    "\e[36m",
      reset:   "\e[0m"
    }
    module Themes
      DEFAULT = {
        pass:     :green,
        fail:     :red,
        error:    :magenta,
        pending:  :teal
      }
    end

    def self.cprint(status, *strings)
      color = RCheck.colors[status] ||
              raise("invalid status: #{status.inspect}")
      code  = ESC[color] || raise("invalid color #{color.inspect}")
      print "#{code}#{strings.join}#{ESC[:reset]}"
    end

    def self.show_legend
      return unless STDOUT.tty?
      RCheck.colors.each do |key, value|
        print ' '
        cprint key, key
      end
      puts
    end
  end
end
