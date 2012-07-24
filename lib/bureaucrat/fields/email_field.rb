require 'bureaucrat/fields/regex_field'

module Bureaucrat
  module Fields
    class EmailField < RegexField
      EMAIL = /
      (^[-!#\$%&'*+\/=?^_`{}|~0-9A-Z]+(\.[-!#\$%&'*+\/=?^_`{}|~0-9A-Z]+)*
       |^"([\001-\010\013\014\016-\037!#-\[\]-\177]|\\[\001-\011\013\014\016-\177])*"
      )@(?:[A-Z0-9]+(?:-*[A-Z0-9]+)*\.)+[A-Z]{2,6}$/xi

      def initialize(options={})
        super(EMAIL, options)
      end

      def clean(value)
        value = to_object(value).strip
        super(value)
      end
    end
  end
end
