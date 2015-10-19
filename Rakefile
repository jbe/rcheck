require 'bundler/gem_tasks'
require 'rake/testtask'

task default: [:test]

desc 'Run all tests'
task :test do
  system 'ruby test/run.rb'
end

desc 'Open interactive console'
task :console do
  require 'bundler/setup'
  require 'rcheck'
  require 'pry'
  Pry.start
end
