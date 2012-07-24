require 'bureaucrat/validators/base'

module Bureaucrat
  module Validators
    class MinValueValidator < BaseValidator
      def message
        I18n.t('bureaucrat.default_errors.validators.min_value_validator')
      end

      def code
        :min_value
      end

      def compare(a, b)
        a < b
      end
    end
  end
end
