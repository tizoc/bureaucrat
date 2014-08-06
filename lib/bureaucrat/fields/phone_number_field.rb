require 'bureaucrat/fields/regex_field'

module Bureaucrat
  module Fields
    class PhoneNumberField < RegexField
      US_PHONE_NUMBER = /^(1?( |-)??(\()?(-|\.)?[0-9]{3}(\))?)?(-|\.| )?[0-9]{3}(-|\.| )?[0-9]{4}$/

      def initialize(options={})
        super(US_PHONE_NUMBER, options)
      end

      def clean(value)
        value = to_object(value).strip
        super(value)
      end
    end
  end
end

