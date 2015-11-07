require 'pathname'

module RCheck
  module Backtrace
    class Line
      attr_reader(*%i(file line))
      def initialize(str)
        @file, @line, @scope = str.split(':')
        @line = line.to_i
        @file = Pathname.new(File.expand_path(file)).relative_path_from Pathname.new(Dir.pwd)
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
