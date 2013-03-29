require 'bureaucrat/validators/base'

module Bureaucrat
  module Validators
    class MaxLengthValidator < BaseValidator
      def message
        I18n.t('bureaucrat.default_errors.validators.max_length_validator')
      end

      def code
        :max_length
      end

      def compare(a, b)
        a > b
      end

      def clean(x)
        x.length
      end
    end
  end
end
