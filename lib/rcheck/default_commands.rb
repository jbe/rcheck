module RCheck
  Command.hide [:_base, :_default]

  define :_base, 'used as a base for all other commands', Options::BASE
  define :_default, 'used when nothing else given', Options::DEFAULT

  define :quiet, 'turn off all reporting and headers',
    headers: [], progress: [], report: []

  define :tree, 'show all suites in a tree',
    :quiet, report: ReportPrinters::Tree.new(show: :all)

  define :list, 'show list of problematic assertions',
    :quiet, report: ReportPrinters::List.new(show: :problematic)

  define :all, 'list all assertions',
    :quiet, report: ReportPrinters::List.new(show: :all)

  define :numbers, 'show assertion counts',
    :quiet, report: 'numbers'

  # define(:html,
  #   progress_printers:  [],
  #   report_printers:    [:Html]
  # )

  define :itself, 'run RCheck\'s own test suite',
    :_default, files: "#{RCheck.which}/tests/**/*.rb"
end
