require 'bureaucrat/widgets/input'

module Bureaucrat
  module Widgets
    class PasswordInput < Input
      def initialize(attrs = nil, render_value = false)
        super(attrs)
        @render_value = render_value
      end

      def input_type
        'password'
      end

      def render(name, value, attrs=nil)
        value = nil unless @render_value
        super(name, value, attrs)
      end
    end
  end
end
