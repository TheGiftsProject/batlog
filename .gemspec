# -*- encoding: utf-8 -*-
require "./lib/log/version"

Gem::Specification.new do |s|
  s.name        = 'batlog'
  s.version     = Log::VERSION
  s.summary     = "A structured logging system"
  s.authors      = ["Asaf Gartner", "Yonatan Bergman"]
  s.email       = 'agartner@ebay.com'
  s.platform    = Gem::Platform::RUBY

  s.files       = `git ls-files`.split("\n")
  s.require_path = "lib"

  s.add_dependency "rails"
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'

  s.test_files = Dir.glob('spec/lib/*_spec.rb')

  s.post_install_message = "Run 'rails generate db_log' and then migrate to start using the log with database backend"
end
