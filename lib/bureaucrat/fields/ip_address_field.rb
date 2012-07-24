require 'bureaucrat/fields/char_field'
require 'bureaucrat/validators'

module Bureaucrat
  module Fields
    class IPAddressField < CharField
      def default_error_messages
        super.merge(invalid: 'Enter a valid IPv4 address.')
      end

      def default_validators
        [Validators::ValidateIPV4Address]
      end
    end
  end
end
