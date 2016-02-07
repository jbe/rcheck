# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rcheck/version'

Gem::Specification.new do |spec|
  spec.name          = 'rcheck'
  spec.version       = RCheck::VERSION
  spec.authors       = ['Jostein Berre Eliassen']
  spec.email         = []

  spec.summary       = 'RCheck < RSpec'
  spec.description   = 'Tests that are very simple, useful and quick'
  spec.homepage      = 'https://github.com/jbe/rcheck'

  spec.require_paths = ['lib']
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'pry'
end
