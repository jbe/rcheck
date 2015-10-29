module RCheck
  invocation :_base,  'always used before other invocations',
    files:            './tests/**/*.rb',
    suite:            [],
    seed:             rand(10000),
    print_order:      :run,
    colors:           :default,
    filters:          %i(installed_gems executables rcheck jruby),
    anti_filters:     %i(cwd),
    progress:         [],
    report:           [],
    success_code:     0,
    fail_code:        1,
    headers:          %i(rcheck platform commit)

  invocation :default,  'used when no other invocations are given',
    progress:  %i(progress_bar),
    report:    %i(tree list numbers)

  invocation :quiet,   'turn off all reporting and headers',
    headers:   :none,
    progress:  %i(),
    report:    %i()

  invocation :ignore,   'set fail_code to 0',
    fail_code: 0

  invocation :tree,     'show all suites in a tree',
    :quiet, :ignore,
    report:    ReportPrinters::Tree.new(show: :all)

  invocation :list,     'only show list of problematic assertions',
    :quiet, :ignore,
    report:    ReportPrinters::List.new(show: :problematic)

  invocation :numbers,     'show assertion counts',
    :quiet, :ignore,
    report:    :numbers

  # invocation(:html,
  #   progress_printers:  %i(),
  #   report_printers:    %i(Html)
  # )

  invocation :myself, 'run RCheck\'s own test suite',
    :default,
    files: "#{RCheck.which}/tests/**/*.rb"
end
