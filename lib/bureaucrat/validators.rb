module Bureaucrat
  module Validators
    extend self

    def empty_value?(value)
      value.nil? || value == '' || value == [] || value == {}
    end

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
          raise ValidationError.new(@message, code, :regex => regex)
        end
      end
    end

    def validate_integer
      @@validate_integer ||= lambda do |value|
        begin
          Integer(string)
        rescue ArgumentError
          raise ValidationError.new('')
        end
      end
    end

    # Original from Django's EmailField:
    # email_re = re.compile(
    #    r"(^[-!#$%&'*+/=?^_`{}|~0-9A-Z]+(\.[-!#$%&'*+/=?^_`{}|~0-9A-Z]+)*"  # dot-atom
    #    r'|^"([\001-\010\013\014\016-\037!#-\[\]-\177]|\\[\001-011\013\014\016-\177])*"' # quoted-string
    #    r')@(?:[A-Z0-9]+(?:-*[A-Z0-9]+)*\.)+[A-Z]{2,6}$', re.IGNORECASE)  # domain
    EMAIL_RE = /(^[-!#\$%&'*+\/=?^_`{}|~0-9A-Z]+(\.[-!#\$%&'*+\/=?^_`{}|~0-9A-Z]+)*|^"([\001-\010\013\014\016-\037!#-\[\]-\177]|\\[\001-011\013\014\016-\177])*")@(?:[A-Z0-9]+(?:-*[A-Z0-9]+)*\.)+[A-Z]{2,6}$/i

    def validate_email
      @@validate_email ||=
        RegexValidator.new(:regex => EMAIL_RE,
                           :message => 'Enter a valid e-mail address.',
                           :code => :invalid)
    end

    SLUG_RE = /^[-\w]+$/

    def validate_slug
      @@validate_slug ||=
        RegexValidator.new(:regex => SLUG_RE,
                           :message => "Enter a valid 'slug' consisting of letters, numbers, underscores or hyphens.",
                           :code => :invalid)
    end

    IPV4_RE = /^(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3}$/

    def validate_ipv4_address
      @@validate_ipv4_address ||=
        RegexValidator.new(:regex => IPV4_RE,
                           :message => 'Enter a valid IPv4 address.',
                           :code => 'invalid')
    end

    COMMA_SEPARATED_INT_LIST_RE = /^[\d,]+$/

    def validate_comma_separated_integer_list
      @@validate_comma_separated_integer_list ||=
        RegexValidator.new(:regex => COMMA_SEPARATED_INT_LIST_RE,
                           :message => 'Enter only digits separated by commas.',
                           :code => :invalid)
    end

    class BaseValidator
      def initialize(limit_value)
        @limit_value = limit_value
      end

      def message
        'Ensure this value is %(limit_value)s (it is %(show_value)s).'
      end

      def code
        :limit_value
      end

      def compare(a, b)
        a.object_id != b.object_id
      end

      def clean(x)
        x
      end

      def call(value)
        cleaned = clean(value)
        params = { :limit_value => @limit_value, :show_value => cleaned }

        if compare(cleaned, @limit_value)
          msg = Utils.format_string(message, params)
          raise ValidationError.new(msg, code, params)
        end
      end
    end

    class MaxValueValidator < BaseValidator
      def message
        'Ensure this value is less than or equal to %(limit_value)s.'
      end

      def code
        :max_value
      end

      def compare(a, b)
        a > b
      end
    end

    class MinValueValidator < BaseValidator
      def message
        'Ensure this value is greater than or equal to %(limit_value)s.'
      end

      def code
        :min_value
      end

      def compare(a, b)
        a < b
      end
    end

    class MinLengthValidator < BaseValidator
      def message
        'Ensure this value has at least %(limit_value)d characters (it has %(show_value)d).'
      end

      def code
        :min_length
      end

      def compare(a, b)
        a < b
      end

      def clean(x)
        x.length
      end
    end

    class MaxLengthValidator < BaseValidator
      def message
        'Ensure this value has at most %(limit_value)d characters (it has %(show_value)d).'
      end

      def code
        :max_length
      end

      def compare(a, b)
        a > b
      end

      def clean(x)
        x.length
      end
    end
  end
end
