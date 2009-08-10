require 'bureaucrat/utils'
require 'bureaucrat/validation'
require 'bureaucrat/widgets'

module Bureaucrat
module Fields

  class ErrorList < Array
    include Utils

    def to_s
      as_ul
    end

    def as_ul
      ul = '<ul class="errorlist">%s</ul>'
      li = '<li>%s</li>'
      empty? ? '' : mark_safe(ul % map {|e| li % conditional_escape(e)}.join("\n"))
    end

    def as_text
      empty? ? '' : map{|e| '* %s' % e}.join("\n")
    end
  end

  class ErrorHash < Hash
    include Utils

    def to_s
      as_ul
    end

    def as_ul
      ul = '<ul class="errorlist">%s</ul>'
      li = '<li>%s%s</li>'
      empty? ? '' : mark_safe(ul % map {|k, v| li % [k, v]}.join)
    end

    def as_text
      map do |k, v|
        '* %s\n%s' % [k, v.map{|i| '  * %s'}.join("\n")]
      end.join("\n")
    end
  end

  class FieldValidationError < Exception
    attr_reader :messages

    def initialize(message)
      message = [message] unless message.is_a?(Array)
      @messages = ErrorList.new(message)
    end

    def to_s
      @messages.inspect
    end
  end

  class Field
    include Validation::Validators
    include Validation::Converters

    class << self
      attr_reader :default_error_messages

      def set_error(key, template)
        @default_error_messages ||= {}
        @default_error_messages[key] = template
      end

      def widget(widget=nil)
        @widget = widget unless widget.nil?
        @widget
      end

      def hidden_widget(hidden_widget=nil)
        @hidden_widget = hidden_widget unless hidden_widget.nil?
        @hidden_widget
      end

      # Copy field properties to the child class
      def inherited(c)
        c.widget        widget
        c.hidden_widget hidden_widget
        default_error_messages.each {|k, v| c.set_error k, v}
      end
    end

    # Field properties
    widget        Widgets::TextInput
    hidden_widget Widgets::HiddenInput
    set_error     :required, 'This field is required'
    set_error     :invalid, 'Enter a valid value'

    attr_accessor :required, :label, :initial, :error_messages, :widget, :show_hidden_initial, :help_text

    def initialize(options={})
      @required = options.fetch(:required, true)
      @show_hidden_initial = options.fetch(:show_hidden_initial, false)
      @label = options[:label]
      @initial = options[:initial]
      @help_text = options.fetch(:help_text, '')
      @widget = options.fetch(:widget, self.class.widget)

      @widget = @widget.new if @widget.is_a?(Class)
      extra_attrs = widget_attrs(@widget)
      @widget.attrs.update(extra_attrs) if extra_attrs

      @error_messages = self.class.default_error_messages.
        merge(options.fetch(:error_messages, {}))
    end

    def validating
      yield
    rescue Validation::ValidationError => error
      tpl = error_messages.fetch(error.error_code, error.error_code.to_s)
      msg = Utils.format_string(tpl, error.parameters)
      raise FieldValidationError.new(msg)
    end

    def clean(value)
      validating { is_present(value) if @required }
      value
    end

    def widget_attrs(widget)
      # Override to add field specific attributes
    end

    def initialize_copy(original)
      super(original)
      @initial = original.initial ? original.initial.dup : original.initial
      @label = original.label ? original.label.dup : original.label
      @error_messages = original.error_messages.dup
    end

  end

  class CharField < Field
    set_error :max_length, 'Ensure this value has at most %(max)s characters (it has %(length)s).'
    set_error :min_length, 'Ensure this value has at least %(min)s characters (it has %(length)s).'

    attr_accessor :max_length, :min_length

    def initialize(options={})
      @max_length = options.delete(:max_length)
      @min_length = options.delete(:min_length)
      super(options)
    end

    def widget_attrs(widget)
      return if @max_length.nil?
      return {:maxlength => @max_length.to_s} if
        widget.kind_of?(Widgets::TextInput) || widget.kind_of?(Widgets::PasswordInput)
    end

    def clean(value)
      super(value)
      return '' if empty_value?(value)

      validating do
          has_max_length(value, @max_length) if @max_length
          has_min_length(value, @min_length) if @min_length
        end

      value
    end
  end

  class IntegerField < Field
    set_error :invalid, 'Enter a whole number.'
    set_error :max_value, 'Ensure this value is less than or equal to %(max)s.'
    set_error :min_value, 'Ensure this value is greater than or equal to %(min)s.'

    def initialize(options={})
      @max_value = options.delete(:max_value)
      @min_value = options.delete(:min_value)
      super(options)
    end

    def clean(value)
      super(value)
      return nil if empty_value?(value)

      validating do
          value = to_integer(value)
          is_not_greater_than(value, @max_value) if @max_value
          is_not_lesser_than(value, @min_value) if @min_value
        end

      value
    end
  end

  class FloatField < Field
    set_error :invalid, 'Enter a number.'
    set_error :max_value, 'Ensure this value is less than or equal to %(max)s.'
    set_error :min_value, 'Ensure this value is greater than or equal to %(min)s.'

    def initialize(options={})
      @max_value = options.delete(:max_value)
      @min_value = options.delete(:min_value)
      super(options)
    end

    def clean(value)
      super(value)
      return nil if empty_value?(value)

      validating do
          value = to_float(value)
          is_not_greater_than(value, @max_value) if @max_value
          is_not_lesser_than(value, @min_value) if @min_value
        end

      value
    end
  end

  class BigDecimalField < Field
    set_error :invalid, 'Enter a number.'
    set_error :max_value, 'Ensure this value is less than or equal to %(max)s.'
    set_error :min_value, 'Ensure this value is greater than or equal to %(min)s.'
    set_error :max_digits, 'Ensure that there are no more than %(max)s digits in total.'
    set_error :max_decimal_places, 'Ensure that there are no more than %(max)s decimal places.'
    set_error :max_whole_digits, 'Ensure that there are no more than %(max)s digits before the decimal point.'

    def initialize(options={})
      @max_value = options.delete(:max_value)
      @min_value = options.delete(:min_value)
      @max_digits = options.delete(:max_digits)
      @max_decimal_places = options.delete(:max_decimal_places)
      @whole_digits = @max_digits - @decimal_places if @max_digits && @decimal_places
      super(options)
    end

    def clean(value)
      super(value)
      return nil if !@required && empty_value?(value)

      validating do
          value = to_big_decimal(value.to_s.strip)
          is_not_greater_than(value, @max_value) if @max_value
          is_not_lesser_than(value, @min_value) if @min_value
          has_max_digits(value, @max_digits) if @max_digits
          has_max_decimal_places(value, @max_decimal_places) if @max_decimal_places
          has_max_whole_digits(value, @max_whole_digits) if @max_whole_digits
        end

      value
    end
  end

  # DateField
  # TimeField
  # DateTimeField

  class RegexField < CharField
    def initialize(regex, options={})
      error_message = options.delete(:error_message)
      if error_message
        options[:error_messages] ||= {}
        options[:error_messages][:invalid] = error_messages
      end
      super(options)
      @regex = regex
    end

    def clean(value)
      value = super(value)
      return value if value.empty?
      validating { matches_regex(value, @regex) }
      value
    end
  end

  class EmailField < RegexField
    # Original from Django's EmailField:
    # email_re = re.compile(
    #    r"(^[-!#$%&'*+/=?^_`{}|~0-9A-Z]+(\.[-!#$%&'*+/=?^_`{}|~0-9A-Z]+)*"  # dot-atom
    #    r'|^"([\001-\010\013\014\016-\037!#-\[\]-\177]|\\[\001-011\013\014\016-\177])*"' # quoted-string
    #    r')@(?:[A-Z0-9]+(?:-*[A-Z0-9]+)*\.)+[A-Z]{2,6}$', re.IGNORECASE)  # domain
    EMAIL_RE = /(^[-!#\$%&'*+\/=?^_`{}|~0-9A-Z]+(\.[-!#\$%&'*+\/=?^_`{}|~0-9A-Z]+)*|^"([\001-\010\013\014\016-\037!#-\[\]-\177]|\\[\001-011\013\014\016-\177])*")@(?:[A-Z0-9]+(?:-*[A-Z0-9]+)*\.)+[A-Z]{2,6}$/i

    set_error :invalid, 'Enter a valid e-mail address.'

    def initialize(options={})
      super(EMAIL_RE, options)
    end
  end

  # TODO: add tests
  class FileField < Field
    widget    Widgets::FileInput
    set_error :invalid, 'No file was submitted. Check the encoding type on the form.'
    set_error :missing, 'No file was submitted.'
    set_error :empty, 'The submitted file is empty.'
    set_error :max_length, 'Ensure this filename has at most %(max)d characters (it has %(length)d).'

    def initialize(options)
      @max_length = options.delete(:max_length)
      super(options)
    end

    def clean(data, initial=nil)
      super(initial || data)

      if !required && empty_value?(data)
        return nil
      elsif !data && initial
        return initial
      end

      # TODO: file validators?
      validating do
          # UploadedFile objects should have name and size attributes.
          begin
            file_name = data.name
            file_size = data.size
          rescue NoMethodError
            fail_with(:invalid)
          end

          fail_with(:max_length, :max => @max_length, :length => file_name.length) if
            @max_length && file_name.length > @max_length

          fail_with(:invalid) unless file_name
          fail_with(:empty) unless file_size || file_size == 0
        end

      data
    end
  end

  #class ImageField < FileField
  #end

  # URLField

  class BooleanField < Field
    widget Widgets::CheckboxInput

    def clean(value)
      value = to_bool(value)
      super(value)
      validating { is_true(value) if @required }
      value
    end
  end

  class NullBooleanField < BooleanField
    widget Widgets::NullBooleanSelect

    def clean(value)
      case value
      when true, 'true', '1' then true
      when false, 'false', '0' then false
      else nil
      end
    end
  end

  class ChoiceField < Field
    widget    Widgets::Select
    set_error :invalid_choice, 'Select a valid choice. %(value)s is not one of the available choices.'

    def initialize(choices=[], options={})
      options[:required] = options.fetch(:required, true)
      super(options)
      self.choices = choices
    end

    def choices
      @choices
    end

    def choices=(value)
      @choices = @widget.choices = value.to_a
    end

    def clean(value)
      value = super(value)
      value = '' if empty_value?(value)
      value = value.to_s

      return value if value.empty?

      validating do
          fail_with(:invalid_choice, :value => value) unless valid_value?(value)
        end

      value
    end

    def valid_value?(value)
      @choices.each do |k, v|
          if v.is_a?(Array)
            # This is an optgroup, so look inside the group for options
            v.each do |k2, v2|
              return true if value == k2.to_s
            end
          else
            return true if value == k.to_s
          end
        end
      false
    end
  end

  # TODO: tests
  class TypedChoiceField < ChoiceField
    def initialize(choices=[], options={})
      @coerce = options.delete(:coerce) || lambda{|val| val}
      @empty_value = options.fetch(:empty_value, '')
      options.delete(:empty_value)
      super(choices, options)
    end

    def clean(value)
      value = super(value)
      return @empty_value if value == @empty_value || empty_value?(value)

      begin
        @coerce.call(value)
      rescue
        validating { fail_with(:invalid_choice, :value => value) }
      end
    end
  end

  # TODO: tests
  class MultipleChoiceField < ChoiceField
    widget        Widgets::SelectMultiple
    hidden_widget Widgets::MultipleHiddenInput
    set_error     :invalid_choice, 'Select a valid choice. %(value)s is not one of the available choices.'
    set_error     :invalid_list, 'Enter a list of values.'

    def clean(value)
      validating do
          is_present(value) if @required
          return [] if ! @required && ! value || value.empty?
          is_array(value)
          not_empty(value) if @required

          new_value = value.map(&:to_s)
          new_value.each do |val|
            fail_with(:invalid_choice, :value => val) unless valid_value?(val)
          end
        end

      new_value
    end
  end

  # ComboField
  # MultiValueField
  # FilePathField
  # SplitDateTimeField
  # IPAddressField
  # SlugField
end; end
