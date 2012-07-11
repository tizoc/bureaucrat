require 'bureaucrat/fields/field'

module Bureaucrat
  module Fields
    class IntegerField < Field
      def initialize(options={})
        @max_value = options.delete(:max_value)
        @min_value = options.delete(:min_value)
        super(options)

        if @min_value
          validators << Validators::MinValueValidator.new(@min_value)
        end

        if @max_value
          validators << Validators::MaxValueValidator.new(@max_value)
        end
      end

      def default_error_messages
        super.merge(invalid: error_message(:integer, :invalid),
                    max_value: error_message(:integer, :max_value),
                    min_value: error_message(:integer, :min_value))
      end

      def to_object(value)
        value = super(value)

        if Validators.empty_value?(value)
          return nil
        end

        begin
          Integer(value.to_s)
        rescue ArgumentError
          raise ValidationError.new(error_messages[:invalid])
        end
      end
    end
  end
end
