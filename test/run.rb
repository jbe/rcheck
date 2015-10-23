
$:.unshift(File.dirname(__FILE__) + "/../lib/")
require 'rubygems'
require 'bundler/setup'
require 'rcheck'

RCheck::Runner.new(
  progress_printers: %i(ProgressBar),
  report_printers: %i(ExpandedFailTree RedList Numbers),
  colors: :default,
  backtrace_filters: RCheck::BacktraceFilters::Default.new(include: [])
).run('test/**/*_test.rb')
