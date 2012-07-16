module Bureaucrat
  module Widgets
    class Range < Widget
      def initialize(options = {})
        super(options)
        @min = TextInput.new(options[:min])
        @max = TextInput.new(options[:max])
        @separator = options[:separator].to_s
        @suffix = options[:suffix].to_s
      end

      def render(name, value, attrs={})
        value ||= {}
        html = ""
        html << @min.render("#{name}[min]", value[:min], attrs[:min])
        html << " " << @separator << " "
        html << @max.render("#{name}[max]", value[:max], attrs[:max])
        html << " " << @suffix
        html
      end

    end
  end
end
