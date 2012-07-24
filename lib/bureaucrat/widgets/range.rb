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
        html = "<a name=\"#{name}\" />"
        html << @min.render("#{name}[min]", value[:min], attrs[:min])
        html << " " << @separator << " "
        html << @max.render("#{name}[max]", value[:max], attrs[:max])
        html << " " << @suffix
        html
      end
    end
  end
end
