require 'bureaucrat/fields/regex_field'

module Bureaucrat
  module Fields
    class SlugField < RegexField
      SLUG = /^[-\w]+$/

      def initialize(options={})
        super(SLUG, options)
      end

      def clean(value)
        value = to_object(value).strip
        super(value)
      end
    end
  end
end
