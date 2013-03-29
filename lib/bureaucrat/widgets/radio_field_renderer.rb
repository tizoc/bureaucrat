require 'bureaucrat/widgets/radio_input'

module Bureaucrat
  module Widgets
    class RadioFieldRenderer
      include Utils

      def initialize(name, value, attrs, choices)
        @name = name
        @value = value
        @attrs = attrs
        @choices = choices
      end

      def each
        @choices.each_with_index do |choice, i|
          yield RadioInput.new(@name, @value, @attrs.dup, choice, i)
        end
      end

      def [](idx)
        choice = @choices[idx]
        RadioInput.new(@name, @value, @attrs.dup, choice, idx)
      end

      def to_s
        render
      end

      def render
        list = []
        li_attrs = @attrs.delete(:li_attrs) { {} }
        each {|radio| list << "<li#{flatatt(li_attrs)}>#{radio}</li>"}
        mark_safe("<ul>\n#{list.join("\n")}\n</ul>")
      end
    end
  end
end
