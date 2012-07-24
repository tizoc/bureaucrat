require 'bureaucrat/validators/regex'

module Bureaucrat
  module Validators
    IPV4_RE = /^(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3}$/

    ValidateIPV4Address = lambda do |value|
      validator = RegexValidator.new(regex: IPV4_RE,
                         message: I18n.t('bureaucrat.default_errors.validators.validate_ipv4_address'))
      validator.call(value)
    end

    IPV4Validator = ValidateIPV4Address
  end
end
