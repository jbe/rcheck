require 'bundler/gem_tasks'

task default: [:test]

desc 'Run all tests'
task :test do
  require_relative 'test/run.rb'
end

desc 'Open interactive console'
task :console do
  require 'bundler/setup'
  require 'rcheck'
  require 'pry'
  Pry.start
end
