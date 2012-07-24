require 'bureaucrat/validators/regex'

module Bureaucrat
  module Validators
    SLUG_RE = /^[-\w]+$/

    ValidateSlug = lambda do |value|
      validator = RegexValidator.new(regex: SLUG_RE,
                         message: I18n.t('bureaucrat.default_errors.validators.validate_slug'))
      validator.call(value)
    end
  end
end
