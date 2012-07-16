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
        value_array = value.values.map(&:to_i)
        {:min => value_array.min, :max => value_array.max}
      end

      def default_widget
        Widgets::Range
      end
    end
  end
end

