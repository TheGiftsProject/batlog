# -*- encoding: utf-8 -*-
require "lib/log/version"

Gem::Specification.new do |s|
  s.name        = 'log'
  s.version     = Log::VERSION
  s.summary     = "A structured logging system"
  s.author      = "Asaf Gartner"
  s.email       = 'agartner@ebay.com'
  s.platform    = Gem::Platform::RUBY

  s.files       = `git ls-files`.split("\n")
  s.require_path = "lib"

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency "rails"

  s.test_files = Dir.glob('spec/*_spec.rb')
end
