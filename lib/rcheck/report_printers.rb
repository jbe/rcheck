
module RCheck
  module ReportPrinters
    class Abstract
      include Colors::Mixin

      def initialize(opts={})
        @opts = opts
        @opts[:show] ||= :problematic
      end
    end

    class List < Abstract
      def report(suite)
        suite.local(*@opts[:show]).each do |item|
          location = item.backtrace.first
          cprint item.status, "  %-8s #{location}:" % [item.status.capitalize]
          cputs :quiet, " (#{suite.full_name})"
          if (item.status != :pending)
            cprint :quiet, "  %-8s " % ['']
            # TODO source inspect at error site
            print location.source
            if item.introspection
              cprint :quiet, " » "
              cprint :value, item.introspection
            end
            puts
          end
          cputs :quiet, indent(item.multiline)

          if %i(error fail).include?(item.status)
            item.debuggers.each do |dbg|
              cputs :quiet, dbg_indent(dbg.items)
            end
          end
        end

        if suite.total(*%i(error fail)).any?
        end

        suite.children.each do |child_suite|
          report child_suite
        end
      end

      private

      def indent(lines)
        Array(lines).map {|line| (' ' * 11) + line.to_s }
      end

      def dbg_indent(lines)
        Array(lines).map {|line| '         » ' + line.to_s }
      end
    end

    class Tree < Abstract
      def report(suite, indent=0)
        continues = suite.total(*@opts[:show]).any? || suite.parent.nil?

        offset indent
        unless suite.name.nil?
          cprint suite.severity(:total), suite.name

          if suite.total(:all).any?
            cprint :quiet, ' ('
            first = true
            suite.counts(:total).each do |status, count|
              if count > 0
                cprint status, first ? '' : ' ', count
                first = false
              end
            end
            unless continues
              print ' ' unless first
              cprint :quiet, '+'
            end
            cprint :quiet, ')'
          end
          puts
        end

        if continues
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
        print '%9d  Assertions' %
          [suite.total(*%i(pass fail pending)).count]
        if suite.total(:error).any?
          cprint :quiet, ' (not accurate)'
        end
      end
    end
  end
end
