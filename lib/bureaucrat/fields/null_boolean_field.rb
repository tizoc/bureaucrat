require 'bureaucrat/fields/boolean_field'
require 'bureaucrat/fields/null_boolean_field'
require 'bureaucrat/widgets/null_boolean_select'

module Bureaucrat
  module Fields
    class NullBooleanField < BooleanField
      def default_widget
        Widgets::NullBooleanSelect
      end

      def to_object(value)
        case value
        when true, 'true', '1', 'on' then true
        when false, 'false', '0' then false
        else nil
        end
      end

      def validate(value)
      end
    end
  end
end
