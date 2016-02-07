
module RCheck
  module ProgressPrinters
    def self.track_progress!(assertion)
      Conf[:progress].each do |printer|
        printer.report assertion
      end
    end

    BARCHAR = RUBY_VERSION >= "2.0.0" ? 220.chr : "."

    class Bar
      def report(assertion)
        Colors.cprint assertion.status, BARCHAR if STDOUT.tty?
      end
    end
  end
end
