lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'bureaucrat/version'

Gem::Specification.new do |s|
  s.name        = 'bureaucrat-sc'
  s.version     = '0.11.6'
  s.summary     = "Form handling for Ruby inspired by Django forms."
  s.description = "Bureaucrat is a form handling library for Ruby."
  s.author      = "Bruno Deferrari"
  s.email       = "utizoc@gmail.com"
  s.homepage    = "http://github.com/tizoc/bureaucrat"
  s.files       = Dir[File.join('lib', '**', '*.rb')]
  s.files       += Dir[File.join('locales', '**', '*.yml')]

  s.add_runtime_dependency 'i18n',          '~> 0.6'
  s.add_runtime_dependency 'activesupport', '~> 3.2'

  s.add_development_dependency 'rake',  '10.0.3'
  s.add_development_dependency 'rspec', '2.12.0'

  s.require_paths = ['lib']
end
