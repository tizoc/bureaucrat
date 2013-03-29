require 'bureaucrat/widgets/widget'

module Bureaucrat
  module Widgets
    class Textarea < Widget
      def initialize(attrs=nil)
        # The 'rows' and 'cols' attributes are required for HTML correctness.
        default_attrs = {cols: '40', rows: '10'}
        default_attrs.merge!(attrs) if attrs

        super(default_attrs)
      end

      def render(name, value, attrs=nil)
        value ||= ''
        final_attrs = build_attrs(attrs, name: name)
        mark_safe("<textarea#{flatatt(final_attrs)}>#{conditional_escape(value.to_s)}</textarea>")
      end
    end
  end
end
