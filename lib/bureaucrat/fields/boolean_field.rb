require 'bureaucrat/fields/field'

module Bureaucrat
  module Fields
    class BooleanField < Field
      def default_widget
        Widgets::CheckboxInput
      end

      def to_object(value)
        if value.kind_of?(String) && ['false', '0'].include?(value.downcase)
          value = false
        else
          value = Utils.make_bool(value)
        end

        value = super(value)

        if !value && required
          raise ValidationError.new(error_messages[:required])
        end

        value
      end
    end
  end
end
