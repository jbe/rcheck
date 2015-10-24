require 'forwardable'
require 'date'

# base:
require 'rcheck/version'
require 'rcheck/errors'
require 'rcheck/backtrace'
require 'rcheck/assertions'
require 'rcheck/debugging'
require 'rcheck/suite'
require 'rcheck/dsl'

# configuration and running:
require 'rcheck/config_expander'
require 'rcheck/invocation'

# pluggable by configuration:
require 'rcheck/colors'
require 'rcheck/backtrace_filters'
require 'rcheck/progress_printers'
require 'rcheck/report_printers'

require 'rcheck/class_methods'
require 'rcheck/default_invocations'

module RCheck
  ROOT_SUITE     = Suite.new(nil, nil)
  USER_CONF_FILE = File.join Dir.home, '.rcheck'
  require USER_CONF_FILE if File.file? USER_CONF_FILE
end
