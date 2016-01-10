module RCheck
  # Suites and assertions must implement a method called .result,
  # which returns an instance of this class. This is in order to
  # have a fixed interface between test results and report printers.
  # Only the relevant fields should be filled out, as the reporter
  # will ignore empty fields.
  class Result
    attr_reader(
      :suite,         # the suite where the assertion was made
      :status,        # one of: :error, :fail, :pending, :pass
      :location,      # the backtrace of the assertion itself
      :info,          # helpful info and debugging
      :introspection, # inspection of asserted values
      :backtrace)     # the backtrace if there was an error

    def initialize(hash)
      hash.each { |k, v| instance_variable_set "@#{k}", v }
      @info       ||= []
      @backtrace  ||= []
      @location   || raise('assertion did not provide a location')
      unless hash[:progress] == false
        ProgressPrinters.track_progress! self
      end
    end

    def location
      Backtrace.parse @location
    end

    def backtrace
      Backtrace.parse @backtrace
    end

    def info
      Array(@info)
    end
  end
end
