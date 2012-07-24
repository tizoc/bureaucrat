require 'bureaucrat/fields/char_field'

module Bureaucrat
  module Fields
    class RegexField < CharField
      def initialize(regex, options={})
        error_message = options[:error_message]

        if error_message
          options[:error_messages] ||= {}
          options[:error_messages][:invalid] = error_message
        end

        super(options)

        @regex = regex

        validators << Validators::RegexValidator.new(regex: regex)
      end
    end
  end
end
