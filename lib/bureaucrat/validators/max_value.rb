require 'bureaucrat/validators/base'

module Bureaucrat
  module Validators
    class MaxValueValidator < BaseValidator
      def message
        I18n.t('bureaucrat.default_errors.validators.max_value_validator', limit_value: @formatted_value)
      end

      def code
        :max_value
      end

      def compare(a, b)
        a > b
      end
    end
  end
end
