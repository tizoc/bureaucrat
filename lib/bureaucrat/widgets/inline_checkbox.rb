require 'bureaucrat/widgets/base_checkbox_input'

module Bureaucrat
  module Widgets
    class InlineCheckboxInput < BaseCheckboxInput
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

        copy = final_attrs.delete(:copy)

        mark_safe("<div class=#{final_attrs[:class]}><label><input#{flatatt(final_attrs)}/>#{copy}</label></div>")
      end
    end
  end
end
