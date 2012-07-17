Gem::Specification.new do |s|
  s.name = 'bureaucrat'
  s.version = '0.11.5'
  s.summary = "Form handling for Ruby inspired by Django forms."
  s.description = "Bureaucrat is a form handling library for Ruby."
  s.author = "Bruno Deferrari"
  s.email = "utizoc@gmail.com"
  s.homepage = "http://github.com/tizoc/bureaucrat"
  s.files = Dir[File.join('lib', '**', '*.rb')]
  s.files += Dir[File.join('locales', '**', '*.yml')]
  s.files += [
    "README.md",
    "LICENSE",
    "Rakefile",
    "bureaucrat.gemspec"
  ]
  s.add_dependency('i18n', '0.6.0')
  s.add_dependency('activesupport', '3.2.6')
  s.add_development_dependency('rake', '0.9.2.2')
  s.require_paths = ['lib']
end
