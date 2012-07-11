require 'bureaucrat/fields/choice_field'

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
        if !value || Validators.empty_value?(value)
          []
        elsif !value.is_a?(Array)
          raise ValidationError.new(error_messages[:invalid_list])
        else
          value.map(&:to_s)
        end
      end

      def validate(value)
        if required && (!value || Validators.empty_value?(value))
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
