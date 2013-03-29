require 'bureaucrat/validators/base'

module Bureaucrat
  module Validators
    class MinLengthValidator < BaseValidator
      def message
        I18n.t('bureaucrat.default_errors.validators.min_length_validator')
      end

      def code
        :min_length
      end

      def compare(a, b)
        a < b
      end

      def clean(x)
        x.length
      end
    end
  end
end
