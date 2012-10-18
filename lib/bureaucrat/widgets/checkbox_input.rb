require 'bureaucrat/widgets/base_checkbox_input'

module Bureaucrat
  module Widgets
    class CheckboxInput < BaseCheckboxInput
      def render(name, value, attrs=nil)
        final_attrs = build_attrs(attrs, type: 'checkbox', name: name.to_s)

        # FIXME: this is horrible, shouldn't just rescue everything
        result = @check_test.call(value) rescue false

        if result
          final_attrs[:checked] = 'checked'
        end

        unless ['', true, false, nil].include?(value)
          final_attrs[:value] = value.to_s
        end

        mark_safe("<input#{flatatt(final_attrs)} />")
      end
    end
  end
end
