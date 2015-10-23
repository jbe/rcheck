
module RCheck
  module ReportPrinters
    class RedList
      include Colors::Mixin

      def report(suite)
        bad = suite.local(*%i(error fail pending))
        bad.each do |problem|
          location = problem.backtrace.first
          cprint problem.status, "  %-8s #{location}:" % [problem.status.capitalize]
          cputs :quiet, " (#{suite.full_name})"
          cprint :quiet, "  %-8s " % [problem.class.name.split('::').last.downcase]
          puts location.source
          cputs :quiet, indent(problem.message)
          puts
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

    class ExpandedFailTree
      include Colors::Mixin

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
        end

        puts
        if suite.severity(:total) != :pass
          suite.children.each do |child|
            report child, indent + 2
          end
        end
        puts if indent == 0
      end

      def offset(indent)
        print ' ' * indent
      end
    end

    class Numbers
      include Colors::Mixin

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
        2.times { puts }
      end
    end
  end
end
