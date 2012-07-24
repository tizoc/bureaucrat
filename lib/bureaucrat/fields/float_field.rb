require 'bureaucrat/fields/integer_field'

module Bureaucrat
  module Fields
    class FloatField < IntegerField
      def default_error_messages
        super.merge(invalid: error_message(:float, :invalid))
      end

      def to_object(value)
        if Validators.empty_value?(value)
          return nil
        end

        begin
          Utils.make_float(value.to_s)
        rescue ArgumentError
          raise ValidationError.new(error_messages[:invalid])
        end
      end
    end
  end
end
