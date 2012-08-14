require 'bureaucrat/widgets/widget'
require 'bureaucrat/utils'

module Bureaucrat
  module Widgets
    class Range < Widget
      def initialize(options = {})
        super(options)
        sub_widget_class = options[:sub_widget_class] || TextInput
        @min = sub_widget_class.new(options[:min])
        @max = sub_widget_class.new(options[:max])
        @separator = options[:separator].to_s
        @suffix = options[:suffix].to_s
      end

      def render(name, value, attrs={})
        value ||= {}
        html = "<a name=\"#{name}\"></a>"
        html << @min.render("#{name}[min]", value['min'], attrs[:min])
        html << " " << @separator << " "
        html << @max.render("#{name}[max]", value['max'], attrs[:max])
        html << " " << @suffix
        html
      end

      def value_from_formdata(data, name)
        return nil if data.nil?
        Bureaucrat::Utils::StringAccessHash.new({
          'min'=> @min.value_from_formdata(data[name], 'min'),
          'max'=> @max.value_from_formdata(data[name], 'max')
        })
      end
    end
  end
end
