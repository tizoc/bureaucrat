require 'bureaucrat/fields/char_field'
require 'bureaucrat/validators/email'

module Bureaucrat
  module Fields
    class EmailField < CharField
      def default_error_messages
        super.merge(invalid: error_message(:email, :invalid))
      end

      def default_validators
        [Validators::ValidateEmail]
      end

      def clean(value)
        value = to_object(value).strip
        super(value)
      end
    end
  end
end
