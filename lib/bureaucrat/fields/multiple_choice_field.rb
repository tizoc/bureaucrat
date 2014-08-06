require 'bureaucrat/fields/choice_field'
require 'bureaucrat/validation_error'
require 'bureaucrat/widgets/multiple_hidden_input'
require 'bureaucrat/widgets/select_multiple'

module Bureaucrat
  module Fields
    class MultipleChoiceField < ChoiceField
      def default_error_messages
        super.merge(invalid_choice: error_message(:multiple_choice, :invalid_choice),
                    invalid_list: error_message(:multiple_choice, :invalid_list))
      end

      def default_widget
        Widgets::SelectMultiple
      end

      def default_hidden_widget
        Widgets::MultipleHiddenInput
      end

      def to_object(value)
        if value.blank?
          []
        elsif !value.is_a?(Array)
          raise ValidationError.new(error_messages[:invalid_list])
        else
          value.map(&:to_s)
        end
      end

      def validate(value)
        if required && (!value || value.blank?)
          raise ValidationError.new(error_messages[:required])
        end

        value.each do |val|
          unless valid_value?(val)
            msg = Utils.format_string(error_messages[:invalid_choice],
                                      value: val)
            raise ValidationError.new(msg)
          end
        end
      end
    end
  end
end
