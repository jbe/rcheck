require 'bundler/gem_tasks'

task default: "test:all"

def setup
  require 'bundler/setup'
  require 'rcheck'
end


namespace :test do
  desc 'Run all tests'
  task :all do
    setup
    RCheck.invoke!
  end

  namespace :sanity do
    task :axioms do
      RCheck.invoke! suite: 'RCheck/sanity/axioms'
    end
  end

  namespace :generate do
    task :html do
      setup
      RCheck.invoke! :silent, :html
    end
  end
end

desc 'Open interactive console'
task :console do
  setup
  require 'pry'
  Pry.start
end
