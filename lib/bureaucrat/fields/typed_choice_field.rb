require 'bureaucrat/fields/choice_field'
require 'bureaucrat/validation_error'

module Bureaucrat
  module Fields
    class TypedChoiceField < ChoiceField
      def initialize(choices=[], options={})
        @coerce = options[:coerce] || lambda{|val| val}
        @empty_value = options.fetch(:empty_value, '')
        super(choices, options)
      end

      def to_object(value)
        value = super(value)
        original_validate(value)

        if value == @empty_value || value.blank?
          return @empty_value
        end

        begin
          @coerce.call(value)
        rescue TypeError, ValidationError
          msg = Utils.format_string(error_messages[:invalid_choice],
                                    value: value)
          raise ValidationError.new(msg)
        end
      end

      alias_method :original_validate, :validate

      def validate(value)
      end
    end
  end
end
