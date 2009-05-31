require 'bureaucrat/utils'
require 'bureaucrat/widgets'

module Bureaucrat; module Fields
  class Field
    include Utils

    class << self
      attr_accessor :widget, :hidden_widget, :default_error_messages

      # Copy data to the child class
      def inherited(c)
        c.widget = widget
        c.hidden_widget = hidden_widget
        c.default_error_messages = default_error_messages.dup
      end
    end

    self.widget = Widgets::TextInput
    self.hidden_widget = Widgets::HiddenInput
    self.default_error_messages = {
      :required => 'This field is required',
      :invalid => 'Enter a valid value'
    }

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

      messages = {}
      set_class_error_messages(messages, self.class)
      messages.update(options.fetch(:error_messages, {}))
      @error_messages = messages
    end

    def clean(value)
      raise ValidationError.new(@error_messages[:required]) if
        @required && (value.nil? || value.empty?)

      value
    end

    def widget_attrs(widget)
      {}
    end

    def initialize_copy(original)
      super(original)
      @initial = original.initial ? original.initial.dup : original.initial
      @label = original.label ? original.label.dup : original.label
      @error_messages = original.error_messages.dup
    end

  private
    def set_class_error_messages(messages, klass)
      set_class_error_messages(messages, klass.superclass) if klass.superclass
      has_messages = klass.respond_to? :default_error_messages
      messages.update(klass.default_error_messages) if has_messages
    end

    def empty_value?(value)
      value.nil? || value == ''
    end
  end

  class CharField < Field
    self.default_error_messages = {
      :max_length => 'Ensure this value has at most %(max)s characters (it has %(length)s).',
      :min_length => 'Ensure this value has at least %(min)s characters (it has %(length)s).'
    }

    attr_accessor :max_length, :min_length

    def initialize(options={})
      @max_length = options.delete(:max_length)
      @min_length = options.delete(:min_length)
      super(options)
    end

    def clean(value)
      super(value)
      return '' if empty_value?(value)

      raise ValidationError.new(format_string(@error_messages[:max_length],
                                              { :length => value.length,
                                                :max => @max_length })) if
         @max_length && value.length > @max_length

      raise ValidationError.new(format_string(@error_messages[:min_length],
                                              { :length => value.length,
                                                :min => @mix_length })) if
        @min_length && value.length < @min_length

      value
    end
  end

  # TODO: add tests
  class IntegerField < Field
    self.default_error_messages = {
        :invalid => 'Enter a whole number.',
        :max_value => 'Ensure this value is less than or equal to %s.',
        :min_value => 'Ensure this value is greater than or equal to %s.'
    }

    def initialize(options={})
      @max_value = options.delete(:max_value)
      @min_value = options.delete(:min_value)
      super(options)
    end

    def clean(value)
      super(value)
      return nil if empty_value?(value)

      begin
        value = Integer(value)
      rescue ArgumentError
        raise ValidationError.new(@error_messages[:invalid])
      end

      raise ValidationError.new(@error_messages[:max_value] % @max_value) if
        @max_value && value > @max_value

      raise ValidationError.new(@error_messages[:min_value] % @min_value) if
        @min_value && value < @min_value

      value
    end
  end

  # TODO: add tests
  class FloatField < Field
    self.default_error_messages = {
        :invalid => 'Enter a number.',
        :max_value => 'Ensure this value is less than or equal to %s.',
        :min_value => 'Ensure this value is greater than or equal to %s.'
    }

    def initialize(options={})
      @max_value = options.delete(:max_value)
      @min_value = options.delete(:min_value)
      super(options)
    end

    def clean(value)
      super(value)
      return nil if empty_value?(value)

      begin
        value = make_float(value)
      rescue ArgumentError
        raise ValidationError.new(@error_messages[:invalid])
      end

      raise ValidationError.new(@error_messages[:max_value] % @max_value) if
        @max_value && value > @max_value

      raise ValidationError.new(@error_messages[:min_value] % @min_value) if
        @min_value && value < @min_value

      value
    end
  end

  class BigDecimalField < Field
    self.default_error_messages = {
        :invalid => 'Enter a number.',
        :max_value => 'Ensure this value is less than or equal to %s.',
        :min_value => 'Ensure this value is greater than or equal to %s.',
        :max_digits => 'Ensure that there are no more than %s digits in total.',
        :max_decimal_places => 'Ensure that there are no more than %s decimal places.',
        :max_whole_digits => 'Ensure that there are no more than %s digits before the decimal point.'
      }

    def initialize(options={})
      @max_value = options.delete(:max_value)
      @min_value = options.delete(:min_value)
      @max_digits = options.delete(:max_digits)
      @max_decimal_places = options.delete(:max_decimal_places)
      @whole_digits = @max_digits - @decimal_places if
        @max_digits && @decimal_places
      super(options)
    end

    def clean(value)
      super(value)
      return nil if !@required && empty_value?(value)
      value = value.to_s.strip

      begin
        make_float(value)
      rescue ArgumentError
        raise ValidationError.new(@error_messages[:invalid])
      end

      value = BigDecimal.new(value)

      sign, alldigits, _, whole_digits = value.split
      decimals = alldigits.length - whole_digits

      raise ValidationError.new(@error_messages[:max_value] % @max_value) if
        @max_value && value > @max_value

      raise ValidationError.new(@error_messages[:min_value] % @min_value) if
        @min_value && value < @min_value

      raise ValidationError.new(@error_messages[:max_digits] % @max_digits) if
        @max_digits && digits > @max_digits

      raise ValidationError.new(@error_messages[:max_decimal_places] %
                                @decimal_places) if
        @decimal_places && decimals > @decimal_places

      raise ValidationError.new(@error_messages[:max_whole_digits] %
                                @whole_digits) if
        @whole_digits && whole_digits > @whole_digits

      value
    end
  end

  # DateField
  # TimeField
  # DateTimeField
  # TODO: add tests
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
      raise ValidationError.new(@error_messages[:invalid]) if @regexp !~ value
      value
    end
  end

  # TODO: add tests
  class EmailField < RegexField
    # Original from Django's EmailField:
    # email_re = re.compile(
    #    r"(^[-!#$%&'*+/=?^_`{}|~0-9A-Z]+(\.[-!#$%&'*+/=?^_`{}|~0-9A-Z]+)*"  # dot-atom
    #    r'|^"([\001-\010\013\014\016-\037!#-\[\]-\177]|\\[\001-011\013\014\016-\177])*"' # quoted-string
    #    r')@(?:[A-Z0-9]+(?:-*[A-Z0-9]+)*\.)+[A-Z]{2,6}$', re.IGNORECASE)  # domain
    EMAIL_RE = /(^[-!#\$%&'*+\/=?^_`{}|~0-9A-Z]+(\.[-!#\$%&'*+\/=?^_`{}|~0-9A-Z]+)*|^"([\001-\010\013\014\016-\037!#-\[\]-\177]|\\[\001-011\013\014\016-\177])*")@(?:[A-Z0-9]+(?:-*[A-Z0-9]+)*\.)+[A-Z]{2,6}$/i

    self.default_error_messages = {
        :invalid => 'Enter a valid e-mail address.'
      }

    def initialize(options={})
      super(EMAIL_RE, options)
    end
  end

  # TODO: add tests
  class FileField < Field
    self.widget = Widgets::FileInput
    self.default_error_messages = {
      :invalid =>"No file was submitted. Check the encoding type on the form.",
      :missing =>"No file was submitted.",
      :empty =>"The submitted file is empty.",
      :max_length =>'Ensure this filename has at most %(max)d characters (it has %(length)d).'
    }

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

      # UploadedFile objects should have name and size attributes.
      begin
        file_name = data.name
        file_size = data.size
      rescue NoMethodError
        raise ValidationError.new(@error_messages[:invalid])
      end

      if @max_length && file_name.length > @max_length
        error_values = { :max => @max_length, :length => file_name.length }
        raise ValidationError.new(format_string(@error_messages['max_length'],
                                            error_values))
      end

      raise ValidationError.new(@error_messages[:invalid]) unless file_name

      raise ValidationError.new(@error_messages[:empty]) unless
        file_size || file_size == 0

      data
    end
  end

  #class ImageField < FileField
  #end

  # URLField
  # BooleanField
  # NullBooleanField
  # ChoiceField
  # TypedChoiceField
  # MultipleChoiceField
  # ComboField
  # MultiValueField
  # FilePathField
  # SplitDateTimeField
  # IPAddressField
  # SlugField
end; end
