require 'bureaucrat/fields/char_field'

module Bureaucrat
  module Fields
    class SlugField < CharField
      def default_error_messages
        super.merge(invalid: "Enter a valid 'slug' consisting of letters, numbers, underscores or hyphens.")
      end

      def default_validators
        [Validators::ValidateSlug]
      end
    end
  end
end
