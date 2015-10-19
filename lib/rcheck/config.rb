
module RCheck
  class << self
    attr_reader(*%i(progress_printers report_printers colors))

    def colors=(theme)
      if theme.is_a?(Hash)
        @colors = theme
      else
        name = :"#{theme.upcase}"
        if Colors::Themes.const_defined?(name)
          @colors = Colors::Themes.const_get(name)
        else
          raise "Invalid color theme: #{theme.inspect}"
        end
      end
    end

    def progress_printers=(printers)
      @progress_printers = map_printers(ProgressPrinter, printers)
    end
    def report_printers=(printers)
      @report_printers = map_printers(ReportPrinter, printers)
    end
    def map_printers(scope, printers)
      printers.map do |printer|
        case printer
        when Class  then printer.new
        when Symbol then scope.const_get(printer).new
        else printer
        end
      end
    end
  end
end
