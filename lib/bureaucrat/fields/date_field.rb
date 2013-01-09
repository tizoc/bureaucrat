require 'date'
require 'bureaucrat/fields/char_field'
require 'bureaucrat/validation_error'
require 'bureaucrat/widgets/date_input'
require 'bureaucrat/validators/min_value'
require 'bureaucrat/validators/max_value'

module Bureaucrat
  module Fields
    class DateField < CharField
      def initialize(options={})
        @min = options[:min]
        @max = options[:max]
        super(options)
        formatter = lambda { |date| widget.format_date(date) }
        validators << Validators::MinValueValidator.new(@min, formatter) if @min
        validators << Validators::MaxValueValidator.new(@max, formatter) if @max
      end

      def default_error_messages
        super.merge(invalid: error_message(:date, :invalid))
      end

      def default_widget
        Widgets::DateInput
      end

      def to_object(value)
        if value.blank?
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
