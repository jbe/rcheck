require 'pathname'

module RCheck
  module Backtrace
    class Line
      attr_reader(*%i(file line scope))
      def initialize(str)
        @file, @line, @scope = str.split(':')
        @line = line.to_i
        @file = Pathname.new(File.expand_path(file)).relative_path_from Pathname.new(Dir.pwd)
      end

      def to_s
        "#{@file}:#{@line}"
      end

      def source
        src = File.readlines(File.expand_path(@file))[@line-1]
        src && src.strip
      end
    end
  end
end
