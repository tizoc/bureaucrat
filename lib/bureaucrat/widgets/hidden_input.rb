require 'bureaucrat/widgets/input'

module Bureaucrat
  module Widgets
    class HiddenInput < Input
      attr_accessor :choices

      def input_type
        'hidden'
      end

      def hidden?
        true
      end
    end
  end
end
