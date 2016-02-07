
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
          item = item.result
          location = item.location.first
          cprint item.status, "  %-8s #{location.short}:" %
            [item.status.capitalize]
          cputs :quiet, " (#{suite.full_name})"
          if (item.status == :pending)
            cputs(:quiet, *dbg_indent(item.introspection)) if item.reason
          else
            cprint :quiet, "  %-8s " % ['']
            # TODO source inspect at error site
            puts location.source
            # if item.introspection && item.introspection.length > 2000
            #   puts item.class.inspect
            # end
            if item.introspection
              cprint(:value, *indent('> '))
              cputs :quiet, item.introspection
            end
            puts
          end
          cputs :quiet, indent(item.backtrace)

          if [:error, :fail].include?(item.status)
            item.info.each do |dbg|
              cputs :quiet, dbg_indent(dbg)
            end
          end
        end

        # if suite.total(:error, :fail).any?
        # end

        suite.children.each do |child_suite|
          report child_suite
        end
      end

      private

      def indent(lines)
        Array(lines).map {|line| (' ' * 11) + line.to_s }
      end

      ARR = RUBY_VERSION >= "2.0.0" ? 175.chr : ">" # double right arrow

      def dbg_indent(lines)
        Array(lines).map {|line| "         #{ARR} " + line.to_s }
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
            if suite.children.any? and !continues
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
        [:error, :fail, :pending, :pass].each do |status|
          items = suite.total(status)
          if items.any?
            cputs status, "%9d  %s" % [items.count, status.to_s.capitalize]
          end
        end
        print '%9d  Assertions' %
          [suite.total(:pass, :fail, :pending).count]
        if suite.total(:error).any?
          cprint :quiet, ' (not accurate)'
        end
      end
    end
  end
end
