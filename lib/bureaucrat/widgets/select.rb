require 'bureaucrat/widgets/widget'

module Bureaucrat
  module Widgets
    class Select < Widget
      attr_accessor :choices

      def initialize(attrs=nil, choices=[])
        super(attrs)
        @choices = choices.collect
      end

      def render(name, value, attrs=nil, choices=[])
        value = '' if value.nil?
        final_attrs = build_attrs(attrs, name: name)
        output = ["<select#{flatatt(final_attrs)}>"]
        options = render_options(choices, [value])
        output << options if options && !options.empty?
        output << '</select>'
        mark_safe(output.join("\n"))
      end

      def render_options(choices, selected_choices)
        selected_choices = selected_choices.map(&:to_s).uniq
        output = []
        (@choices.to_a + choices.to_a).each do |option_value, option_label|
            option_label ||= option_value
            if option_label.is_a?(Array)
              output << '<optgroup label="%s">' % escape(option_value.to_s)
              option_label.each do |option|
                val, label = option
                output << render_option(val, label, selected_choices)
              end
              output << '</optgroup>'
            else
              output << render_option(option_value, option_label,
                                      selected_choices)
            end
          end
        output.join("\n")
      end

      def render_option(option_attributes, option_label, selected_choices)
        unless option_attributes.is_a?(Hash)
          option_attributes = { value: option_attributes.to_s }
        end

        if selected_choices.include?(option_attributes[:value])
          option_attributes[:selected] = "selected"
        end

        attributes = []

        option_attributes.each_pair do |attr_name, attr_value|
          attributes << %Q[#{attr_name.to_s}="#{escape(attr_value.to_s)}"]
        end

        "<option #{attributes.join(' ')}>#{conditional_escape(option_label.to_s)}</option>"
      end
    end
  end
end
