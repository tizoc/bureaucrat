require 'bureaucrat/widgets/radio_input'
require 'bureaucrat/utils'

module Bureaucrat
  module Widgets
    class RadioInput
      include Utils

      def initialize(name, value, attrs, choice, index)
        @name = name
        @value = value
        @attrs = attrs
        @choice_value = choice[0].to_s
        @choice_label = choice[1].to_s
        @index = index
      end

      def to_s
        label_for = @attrs.include?(:id) ? " for=\"#{@attrs[:id]}_#{@index}\"" : ''
        label_attrs = @attrs.delete(:label_attrs) { {} }
        choice_label = conditional_escape(@choice_label.to_s)
        mark_safe("<label#{label_for}#{flatatt(label_attrs)}>#{tag} #{choice_label}</label>")
      end

      def checked?
        @value == @choice_value
      end

      def tag
        @attrs[:id] = "#{@attrs[:id]}_#{@index}" if @attrs.include?(:id)
        final_attrs = @attrs.merge(type: 'radio', name: @name,
                                   value: @choice_value)
        final_attrs[:checked] = 'checked' if checked?
        mark_safe("<input#{flatatt(final_attrs)} />")
      end
    end
  end
end
