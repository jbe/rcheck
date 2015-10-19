
$:.unshift(File.dirname(__FILE__) + "/../lib/")
require 'rubygems'
require 'bundler/setup'
require 'rcheck'

RCheck.progress_printers  = %i(ProgressBar)
RCheck.report_printers    = %i(RedList ExpandedFailTree Numbers)

puts
RCheck.show_legend
RCheck.require_all 'test/**/*_test.rb'
puts
RCheck.report!
