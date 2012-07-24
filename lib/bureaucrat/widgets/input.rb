require 'bureaucrat/widgets/widget'

module Bureaucrat
  module Widgets
    class Input < Widget
      def render(name, value, attrs=nil)
        value ||= ''
        final_attrs = build_attrs(attrs,
                                  type: input_type.to_s,
                                  name: name.to_s)
        final_attrs[:value] = value.to_s unless value == ''
        mark_safe("<input#{flatatt(final_attrs)} />")
      end

      def input_type
        nil
      end
    end
  end
end
