require 'date'
require 'bureaucrat/fields/date_field'

module Bureaucrat
  module Fields
    class DateField < CharField
      def initialize(input_formats, options={})
        super(options)
        @input_formats = input_formats
      end

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

        if value.is_a? DateTime
          return value.to_date
        end

        if value.is_a? Date
          return value
        end

        @input_formats.each do |format|
          begin
            return Date.strptime(value, format)
          rescue ArgumentError
          end
        end

        raise ValidationError.new(error_messages[:invalid])
      end
    end
  end
end
