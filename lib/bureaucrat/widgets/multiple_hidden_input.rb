require 'bureaucrat/widgets/hidden_input'

module Bureaucrat
  module Widgets
    class MultipleHiddenInput < HiddenInput
      # Used by choice fields
      attr_accessor :choices

      def initialize(attrs=nil, choices=[])
        super(attrs)
        # choices can be any enumerable
        @choices = choices
      end

      def render(name, value, attrs=nil, choices=[])
        value ||= []
        final_attrs = build_attrs(attrs, type: input_type.to_s,
                                  name: "#{name}[]")

        id = final_attrs[:id]
        inputs = []

        value.each.with_index do |v, i|
          input_attrs = final_attrs.merge(value: v.to_s)

          if id
            input_attrs[:id] = "#{id}_#{i}"
          end

          inputs << "<input#{flatatt(input_attrs)} />"
        end

        mark_safe(inputs.join("\n"))
      end
    end
  end
end
