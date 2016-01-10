module RCheck
  module Options
    BASE = {
      files:            %w(./tests/**/*.rb),
      initializers:     %w(./tests/_init.rb ./tests/support/**/*.rb),
      suite:            %w(/),
      seed:             rand(10000),
      print_order:      'run',
      colors:           'default',
      headers:          %w(rcheck platform commit),
      filters:          %w(installed_gems executables rcheck jruby),
      anti_filters:     %w(cwd),
      progress:         [],
      report:           [],
      success_code:     0,
      fail_code:        1,
      max_cols:         138,
      max_rows:         30,
      pry:              false,
      how:              false
    }

    DEFAULT= {
      progress:  %w(bar),
      report:    %w(tree list numbers)
    }

    HELP = {
      files:          'load test files',
      initializers:   'load files before tests',
      suite:          'only show certain suites',
      seed:           'use a fxed seed',
      print_order:    'one of: run, name',
      colors:         'colorscheme',
      headers:        'print report headers',
      filters:        'filter backtrace lines',
      anti_filters:   'exclude backtrace lines from filtering',
      progress:       'use progress printers',
      report:         'use report printers',
      success_code:   'exit code when green',
      fail_code:      'exit code when red',
      max_cols:       'limit width of introspections etc',
      max_rows:       'limit number of lines in traces',
      pry:            'open pry console before running tests',
      how:            'show the parameters produced internally'
    }

    # A hash containg the options that produce the same behaviour
    # as running without any options.
    def self.defaults
      BASE.merge(DEFAULT)
    end

    # A list of valid option names
    def self.names
      BASE.keys
    end
  end
end

