module RCheck
  module Formatting
    def self.truncate(*lines)
      lines.map do |line|
        if line.length < Conf[:max_cols]
          line
        else
          msg = ".. [#{line.length} c]"
          "#{line[0..(Conf[:max_cols] - msg.length)]}#{msg}"
        end
      end
    end
  end

  class Formatter

    def trunc_cols(*lines)
    end

    def trunc_rows(*lines)
      if lines.count < max_rows
        lines
      else
        first     = lines[0..(max_rows/2)]
        last      = lines[(max_rows/2), -1]
        removed   = lines.count - (first + last).count
        first + ["< ! #{removed} lines removed... >"] + last
      end
    end

    def trunc(*lines)
      trunc_cols(*trunc_rows(*lines))
    end

    def indent_with_opts(margin, bullet, bullet_all, *lines)
      pad         = ' ' * margin
      bullet_pad  = (' ' * (margin - 3)) + " #{bullet} "
      result = []
      result << bullet_pad + lines.shift if lines.any?
      lines.each do |line|
        result << (bullet_all ? bullet_pad : pad) + line
      end
      result
    end

    def format_with_bullet(margin, bullet, *lines)
      trunc indent_with_opts(margin, bullet, false, *lines)
    end

    def format_with_bullets(margin, bullet, *lines)
      trunc indent_with_opts(margin, bullet, true, *lines)
    end

    def format(margin, *lines)
      trunc indent_with_opts(margin, ' ', false, *lines)
    end
  end
end
