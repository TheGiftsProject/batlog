Gem::Specification.new do |s|
  s.name        = 'log'
  s.version     = '0.9'
  s.summary     = "A structured logging system"
  s.author      = "Asaf Gartner"
  s.email       = 'agartner@ebay.com'
  s.files       = ["lib/log.rb"]
  s.platform    = Gem::Platform::RUBY
  s.require_path = "lib"

  s.add_development_dependency 'rspec'

  s.test_files = Dir.glob('spec/*_spec.rb')
end
