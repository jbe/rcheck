module RCheck
  invocation :_base,  'always used first',
    files:            './tests/**/*.rb',
    suite:            [],
    seed:             rand(10000),
    order:            :run,
    colors:           :default,
    filter:           :default,
    inspector:        :default,
    progress:         [],
    report:           [],
    success_code:     0,
    fail_code:        1

  invocation :default,  'used when nothing else given',
    progress:  %i(progress_bar),
    report:    %i(tree list numbers)

  invocation :silent,   'turn off all reporting',
    progress:  %i(),
    report:    %i()

  invocation :tree,     'show all suites in a tree',
    report:    ReportPrinters::Tree.new(show: :all)

  invocation :list,     'list all assertions',
    report:    ReportPrinters::List.new(show: :all)

  # invocation(:html,
  #   progress_printers:  %i(),
  #   report_printers:    %i(Html)
  # )

  # invocation :itself,   'run RCheck's own test suite',
  #   files:               #{rcheck_path}/tests/**/*.rb',
end
