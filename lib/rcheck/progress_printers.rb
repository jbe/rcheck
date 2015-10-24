
module RCheck
  module ProgressPrinters
    def self.track_progress!(assertion)
      Invocation[:progress].each do |printer|
        printer.report assertion
      end
    end

    class ProgressBar
      def report(assertion)
        Colors.cprint assertion.status, '▄' if STDOUT.tty?
      end
    end
  end
end
