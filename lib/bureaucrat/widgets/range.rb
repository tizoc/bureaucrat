module Bureaucrat
  module Widgets
    class Range < Widget
      def initialize(options = {})
        @min = TextInput.new(options[:min])
        @max = TextInput.new(options[:max])
      end

      def render(name, value, attrs={})
        html = ""
        html << @min.render("#{name}[min]", value[:min], attrs[:min])
        html << attrs[:separator].to_s
        html << @max.render("#{name}[max]", value[:max], attrs[:max])
        html << attrs[:suffix].to_s
        html
      end

    end
  end
end
