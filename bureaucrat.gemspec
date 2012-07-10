Gem::Specification.new do |s|
  s.name = 'bureaucrat'
  s.version = '0.10.2'
  s.summary = "Form handling for Ruby inspired by Django forms."
  s.description = "Bureaucrat is a form handling library for Ruby."
  s.author = "Bruno Deferrari"
  s.email = "utizoc@gmail.com"
  s.homepage = "http://github.com/tizoc/bureaucrat"

  s.files = [
    "lib/bureaucrat/fields.rb",
    "lib/bureaucrat/forms.rb",
    "lib/bureaucrat/formsets.rb",
    "lib/bureaucrat/quickfields.rb",
    "lib/bureaucrat/temporary_uploaded_file.rb",
    "lib/bureaucrat/utils.rb",
    "lib/bureaucrat/validators.rb",
    "lib/bureaucrat/widgets.rb",
    "lib/bureaucrat.rb",
    "README.md",
    "LICENSE",
    "test/fields_test.rb",
    "test/forms_test.rb",
    "test/formsets_test.rb",
    "test/test_helper.rb",
    "test/widgets_test.rb",
    "Rakefile",
    "bureaucrat.gemspec"
  ]

  s.add_dependency('i18n', '0.6.0')
  s.add_dependency('activesupport', '3.2.6')

  s.add_development_dependency('rake', '0.9.2.2')

  s.require_paths = ['lib']
end
