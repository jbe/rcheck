require 'pathname'

module RCheck
  module Backtrace
    def self.parse(lines)
      lines.reject do |line|
        Conf[:filters].any? { |f| f.match(line) } and
          !Conf[:anti_filters].any? { |f| f.match(line) }
      end.map { |str| Line.new str }
    end

    class Line
      attr_reader(*%i(file line))
      def initialize(str)
        @file, @line, @scope = str.split(':')
        @line = line.to_i
        @file = Pathname.new(File.expand_path(file)).
                relative_path_from Pathname.new(Dir.pwd)
      end

      def short
        "#{@file}:#{@line}"
      end

      def scope
        @scope[4..-2]
      end

      def to_s
        "%-30s %s" % [short, scope]
      end

      def source
        src = File.readlines(File.expand_path(@file))[@line-1]
        src && src.strip
      end
    end
  end
end
