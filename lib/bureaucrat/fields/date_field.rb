require 'date'
require 'bureaucrat/fields/char_field'
require 'bureaucrat/widgets/date_input'

module Bureaucrat
  module Fields
    class DateField < CharField
      def default_error_messages
        super.merge(invalid: error_message(:date, :invalid))
      end

      def default_widget
        Widgets::DateInput
      end

      def to_object(value)
        if Validators.empty_value?(value)
          return nil
        end

        if value.is_a? Date
          return value
        end

        raise ValidationError.new(error_messages[:invalid])
      end
    end
  end
end
