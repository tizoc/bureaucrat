require 'bureaucrat/widgets/widget'

module Bureaucrat
  module Widgets
    class PassThru < Widget

      def choices=(choices)
      end

      def render(name, value, attrs = nil)
        ''
      end

      def pass_thru?
        true
      end
    end
  end
end

