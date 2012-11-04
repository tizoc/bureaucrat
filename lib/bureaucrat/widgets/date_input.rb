require 'bureaucrat/widgets/text_input'

module Bureaucrat
  module Widgets
    class DateInput < TextInput
      def initialize(attrs=nil, input_formats=['%Y-%m-%d'])
        @input_formats = input_formats
        super(attrs)
      end

      def format_date(date)
        date.strftime(@input_formats.first)
      end

      def format_value(value)
        if value.is_a?(Date)
          format_date(value)
        elsif value.is_a?(Time)
          format_date(value.to_date)
        elsif value.is_a?(DateTime)
          format_date(value.to_date)
        else
          begin
            value = Date.parse(value || "")
          rescue ArgumentError
            return value
          end
        end
      end

      def value_from_formdata(data, name)
        value = data[name] || ""
        @input_formats.each do |format|
          begin
            return Date.strptime(value, format)
          rescue ArgumentError
          rescue TypeError
          end
        end
        return value
      end

      def render(name, value, attrs=nil)
        value = format_value(value)
        super(name, value, attrs)
      end
    end
  end
end
