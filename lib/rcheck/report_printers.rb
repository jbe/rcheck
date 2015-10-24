
module RCheck
  module ReportPrinters
    class Abstract
      include Colors::Mixin

      def initialize(opts={})
        @opts = opts
      end
    end

    class List < Abstract
      def report(suite)
        bad = suite.local(*%i(error fail pending))
        bad.each do |problem|
          location = problem.backtrace.first
          cprint problem.status, "  %-8s #{location}:" % [problem.status.capitalize]
          cputs :quiet, " (#{suite.full_name})"
          if problem.status != :pending
            cprint :quiet, "  %-8s " % [problem.class.name.split('::').last.downcase]
            puts location.source
          end
          cputs :quiet, indent(problem.message)
          puts unless problem.status == :pending
        end

        suite.children.each do |child_suite|
          report child_suite
        end
      end

      private
      def indent(lines)
        Array(lines).map {|line| (' ' * 11) + line.to_s }
      end
    end

    class Tree < Abstract
      def report(suite, indent=0)
        offset indent
        unless suite.name.nil?
          cprint suite.severity(:total), suite.name

          cprint :quiet, ' ('
          first = true
          suite.counts(:total).each do |status, count|
            if count > 0
              cprint status, first ? '' : ' ', count
              first = false
            end
          end
          if suite.children.any? and suite.severity(:total) == :pass
            cprint :quiet, ' +'
          end
          cprint :quiet, ')'

          puts
        end

        if (suite.severity(:total) != :pass) || suite.parent.nil?
          suite.children.each do |child|
            report child, indent + 2
          end
        end
      end

      def offset(indent)
        print ' ' * indent
      end
    end

    class Numbers < Abstract
      def report(suite)
        %i(error fail pending pass).each do |status|
          items = suite.total(status)
          if items.any?
            cputs status, "%9d  %s" % [items.count, status.to_s.capitalize]
          end
        end
        puts
        print '%9d  Requirements' %
          [suite.total(*%i(pass fail pending)).count]
        if suite.total(:error).any?
          cprint :quiet, ' (not accurate)'
        end
      end
    end
  end
end
