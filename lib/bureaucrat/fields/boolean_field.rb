require 'bureaucrat/fields/field'
require 'bureaucrat/validation_error'
require 'bureaucrat/widgets/checkbox_input'

module Bureaucrat
  module Fields
    class BooleanField < Field
      def default_widget
        Widgets::CheckboxInput
      end

      def to_object(value)
        if value.kind_of?(String) && ['false', '0'].include?(value.downcase)
          value = false
        elsif !required || !value.nil?
          value = Utils.make_bool(value)
        end

        value = super(value)

        value
      end

      def validate(value)
        if required && value.nil?
          raise ValidationError.new(error_messages[:required])
        end
      end

      def widget_attrs(widget)
        {value: '1'}
      end
    end
  end
end
