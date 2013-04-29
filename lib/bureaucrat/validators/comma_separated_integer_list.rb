require 'bureaucrat/validators/regex'

module Bureaucrat
  module Validators
    COMMA_SEPARATED_INT_LIST_RE = /^[\d,]+$/

    ValidateCommaSeparatedIntegerList = lambda do |value|
      validator = RegexValidator.new(regex: COMMA_SEPARATED_INT_LIST_RE,
                         message: I18n.t('bureaucrat.default_errors.validators.validate_comma_separated_integer_list'))
      validator.call(value)
    end
  end
end
