module Bureaucrat
  VERSION = '0.8.1'

  autoload :Fields,      'bureaucrat/fields'
  autoload :Forms,       'bureaucrat/forms'
  autoload :Utils,       'bureaucrat/utils'
  autoload :Validation,  'bureaucrat/validation'
  autoload :Widgets,     'bureaucrat/widgets'

  # Extra
  autoload :Formsets,    'bureaucrat/formsets'
  autoload :Quickfields, 'bureaucrat/validation'
end
