require 'bureaucrat/validators/regex'

module Bureaucrat
  module Validators
    EMAIL_RE = /
        (^[-!#\$%&'*+\/=?^_`{}|~0-9A-Z]+(\.[-!#\$%&'*+\/=?^_`{}|~0-9A-Z]+)*
        |^"([\001-\010\013\014\016-\037!#-\[\]-\177]|\\[\001-\011\013\014\016-\177])*"
        )@(?:[A-Z0-9]+(?:-*[A-Z0-9]+)*\.)+[A-Z]{2,6}$
    /xi

    ValidateEmail = lambda do |value|
      validator = RegexValidator.new(regex: EMAIL_RE,
                         message: I18n.t('bureaucrat.default_errors.validators.validate_email'))
      validator.call(value)
    end
  end
end
