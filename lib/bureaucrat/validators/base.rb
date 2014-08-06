require 'bureaucrat'

module Bureaucrat
  module Validators
    class BaseValidator
      def initialize(limit_value, formatter=nil)
        @limit_value = limit_value
        @formatted_value = formatter ? formatter.call(limit_value) : limit_value
      end

      def message
        I18n.t('bureaucrat.default_errors.validators.base_validator')
      end

      def code
        :limit_value
      end

      def compare(a, b)
        a.object_id != b.object_id
      end

      def clean(x)
        x
      end

      def call(value)
        cleaned = clean(value)
        params = { limit_value: @formatted_value, show_value: cleaned }

        if compare(cleaned, @limit_value)
          msg = Utils.format_string(message, params)
          raise ValidationError.new(msg, code, params)
        end
      end
    end
  end
end
