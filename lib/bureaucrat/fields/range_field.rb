require 'bureaucrat/fields/field'

module Bureaucrat
  module Fields
    class RangeField < Field
      def initialize(options)
        super(options)
        @min = IntegerField.new(options)
        @max = IntegerField.new(options)
      end

      def clean(value)
        value = super(value)
        value[:min] = @min.clean(value[:min])
        value[:max] = @max.clean(value[:max])
        value
      end

      def to_object(value)
        value.map(&:to_i)
        {:min => value.min, :max => value.max}
      end

    end
  end
end

