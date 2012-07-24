require 'bigdecimal'
require 'bureaucrat/fields/field'
require 'bureaucrat/validators/max_value'
require 'bureaucrat/validators/min_value'

module Bureaucrat
  module Fields
    class BigDecimalField < Field
      def initialize(options={})
        @max_value = options[:max_value]
        @min_value = options[:min_value]
        @max_digits = options[:max_digits]
        @max_decimal_places = options[:max_decimal_places]

        if @max_digits && @max_decimal_places
          @max_whole_digits = @max_digits - @max_decimal_places
        end

        super(options)

        if @min_value
          validators << Validators::MinValueValidator.new(@min_value)
        end

        if @max_value
          validators << Validators::MaxValueValidator.new(@max_value)
        end
      end

      def default_error_messages
        super.merge(invalid: error_message(:big_decimal, :invalid),
                    max_value: error_message(:big_decimal, :max_value, {max: @max_value}),
                    min_value: error_message(:big_decimal, :min_value, {min: @min_value}),
                    max_digits: error_message(:big_decimal, :max_digits, {max: @max_digits}),
                    max_decimal_places: error_message(:big_decimal, :max_decimal_places, {max: @max_decimal_places}),
                    max_whole_digits: error_message(:big_decimal, :max_whole_digits, {max: @max_whole_digits}))
      end

      def to_object(value)
        if value.blank?
          return nil
        end

        begin
          Utils.make_float(value)
          BigDecimal.new(value)
        rescue ArgumentError
          raise ValidationError.new(error_messages[:invalid])
        end
      end

      def validate(value)
        super(value)

        if value.blank?
          return nil
        end

        if value.nan? || value.infinite?
          raise ValidationError.new(error_messages[:invalid])
        end

        sign, alldigits, _, whole_digits = value.split

        if @max_digits && alldigits.length > @max_digits
          msg = Utils.format_string(error_messages[:max_digits],
                                    max: @max_digits)
          raise ValidationError.new(msg)
        end

        decimals = alldigits.length - whole_digits

        if @max_decimal_places && decimals > @max_decimal_places
          msg = Utils.format_string(error_messages[:max_decimal_places],
                                    max: @max_decimal_places)
          raise ValidationError.new(msg)
        end

        if @max_whole_digits && whole_digits > @max_whole_digits
          msg = Utils.format_string(error_messages[:max_whole_digits],
                                    max: @max_whole_digits)
          raise ValidationError.new(msg)
        end

        value
      end
    end
  end
end
