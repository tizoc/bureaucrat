require 'bureaucrat/widgets/widget'

module Bureaucrat
  module Widgets
    class InlineCheckboxInput < Widget
      def initialize(attrs=nil, check_test=nil)
        super(attrs)
        @check_test = check_test || lambda {|v| make_bool(v)}
      end

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
