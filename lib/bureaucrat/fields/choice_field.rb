require 'bureaucrat/fields/field'
require 'bureaucrat/validation_error'
require 'bureaucrat/widgets/select'

module Bureaucrat
  module Fields
    class ChoiceField < Field
      def initialize(choices=[], options={})
        options[:required] = options.fetch(:required, true)
        super(options)
        self.choices = choices
      end

      def initialize_copy(original)
        super(original)
        self.choices = original.choices.dup
      end

      def default_error_messages
        super.merge(invalid_choice: error_message(:choice, :invalid_choice))
      end

      def default_widget
        Widgets::Select
      end

      def choices
        @choices
      end

      def choices=(value)
        @choices = @widget.choices = value
      end

      def to_object(value)
        if value.blank?
          ''
        else
          value.to_s
        end
      end

      def validate(value)
        super(value)

        unless !value || value.blank? || valid_value?(value)
          msg = Utils.format_string(error_messages[:invalid_choice],
                                    value: value)
          raise ValidationError.new(msg)
        end
      end

      def valid_value?(value)
        @choices.each do |k, v|
          if v.is_a?(Array)
            # This is an optgroup, so look inside the group for options
            v.each do |k2, v2|
              return true if value == k2.to_s
            end
          elsif k.is_a?(Hash)
            # this is a hash valued choice list
            return true if value == k[:value].to_s
          else
            return true if value == k.to_s
          end
        end

        false
      end
    end
  end
end
