module Bureaucrat
  module Validators
    class RegexValidator
      attr_accessor :regex, :message, :code

      def initialize(options = {})
        @regex = Regexp.new(options.fetch(:regex, ''))
        @message = options.fetch(:message, 'Enter a valid value.')
        @code = options.fetch(:code, :invalid)
      end

      # Validates that the input validates the regular expression
      def call(value)
        if regex !~ value
          raise ValidationError.new(@message, code, regex: regex)
        end
      end
    end
  end
end
