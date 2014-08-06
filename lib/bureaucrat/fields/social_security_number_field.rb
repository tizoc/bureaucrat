require 'bureaucrat/fields/regex_field'

module Bureaucrat
  module Fields
    class SocialSecurityNumberField < RegexField
      SOCIAL_SECURITY_NUMBER = /^\d{3}-?\d{2}-?\d{4}$/

      def initialize(options={})
        super(SOCIAL_SECURITY_NUMBER, options)
      end

      def clean(value)
        value = to_object(value).strip
        super(value)
      end

    end
  end
end
