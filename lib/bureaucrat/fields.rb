require 'date'
require 'set'

module Bureaucrat
  module Fields

    class ErrorList < Array
      include Utils

      def to_s
        as_ul
      end

      def as_ul
        if empty?
          ''
        else
          ul = '<ul class="errorlist">%s</ul>'
          li = '<li>%s</li>'

          result = ul % map{|e| li % conditional_escape(e)}.join("\n")
          mark_safe(result)
        end
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
          "* %s\n%s" % [k, v.map{|i| '  * %s'}.join("\n")]
        end.join("\n")
      end
    end

    class Field
      attr_accessor :required, :initial, :widget, :hidden_widget, :show_hidden_initial, :help_text, :validators, :form_name, :name

      def initialize(options={})
        @required = options.fetch(:required, true)
        @show_hidden_initial = options.fetch(:show_hidden_initial, false)
        @given_label = options[:label]
        @initial = options[:initial]
        @help_text = options.fetch(:help_text, '')
        @widget = options.fetch(:widget, default_widget)

        @widget = @widget.new if @widget.is_a?(Class)
        @widget.attrs.update(widget_attrs(@widget))
        @widget.is_required = @required

        @hidden_widget = options.fetch(:hidden_widget, default_hidden_widget)
        @hidden_widget = @hidden_widget.new if @hidden_widget.is_a?(Class)

        @given_error_messages = options.fetch(:error_messages, {})

        @validators = default_validators + options.fetch(:validators, [])
      end

      def initialize_copy(original)
        super(original)
        @initial = original.initial
        begin
          @initial = @initial.dup
        rescue TypeError
          # non-clonable
        end
        @given_label = original.label && original.label.dup
        @widget = original.widget && original.widget.dup
        @validators = original.validators.dup
        @given_error_messages = original.error_messages.dup
      end

      # Default error messages for this kind of field. Override on subclasses to add or replace messages
      #
      def label
        @given_label || I18n.t("bureaucrat.#{form_name}.#{name}.label", default: name.to_s.humanize)
      end

      def error_message(scope, error)
        I18n.t("bureaucrat.#{form_name}.#{name}.errors.#{error}", default: I18n.t("bureaucrat.default_errors.#{scope}.#{error}"))
      end

      def default_error_messages
        {
          required: error_message(:field, :required),
          invalid: error_message(:field, :invalid)
        }
      end

      def error_messages
        @error_messages ||= default_error_messages.merge(@given_error_messages)
      end

      # Default validators for this kind of field.
      def default_validators
        []
      end

      # Default widget for this kind of field. Override on subclasses to customize.
      def default_widget
        Widgets::TextInput
      end

      # Default hidden widget for this kind of field. Override on subclasses to customize.
      def default_hidden_widget
        Widgets::HiddenInput
      end

      def prepare_value(value)
        value
      end

      def to_object(value)
        value
      end

      def validate(value)
        if required && Validators.empty_value?(value)
          raise ValidationError.new(error_messages[:required])
        end
      end

      def run_validators(value)
        if Validators.empty_value?(value)
          return
        end

        errors = []

        validators.each do |v|
          begin
            v.call(value)
          rescue ValidationError => e
            if e.code && error_messages.has_key?(e.code)
              message = error_messages[e.code]

              if e.params
                message = Utils.format_string(message, e.params)
              end

              errors << message
            else
              errors += e.messages
            end
          end
        end

        unless errors.empty?
          raise ValidationError.new(errors)
        end
      end

      def clean(value)
        value = to_object(value)
        validate(value)
        run_validators(value)
        value
      end

      # The data to be displayed when rendering for a bound form
      def bound_data(data, initial)
        data
      end

      # List of attributes to add on the widget. Override to add field specific attributes
      def widget_attrs(widget)
        {}
      end

      # Populates object.name if posible
      def populate_object(object, name, value)
        setter = :"#{name}="

        if object.respond_to?(setter)
          object.send(setter, value)
        end
      end

    end

    class CharField < Field
      attr_accessor :max_length, :min_length

      def initialize(options = {})
        @max_length = options.delete(:max_length)
        @min_length = options.delete(:min_length)
        super(options)

        if @min_length
          validators << Validators::MinLengthValidator.new(@min_length)
        end

        if @max_length
          validators << Validators::MaxLengthValidator.new(@max_length)
        end
      end

      def to_object(value)
        if Validators.empty_value?(value)
          ''
        else
          value
        end
      end

      def widget_attrs(widget)
        super(widget).tap do |attrs|
          if @max_length && (widget.kind_of?(Widgets::TextInput) ||
                             widget.kind_of?(Widgets::PasswordInput))
            attrs.merge(maxlength: @max_length.to_s)
          end
        end
      end
    end

    class IntegerField < Field
      def initialize(options={})
        @max_value = options.delete(:max_value)
        @min_value = options.delete(:min_value)
        super(options)

        if @min_value
          validators << Validators::MinValueValidator.new(@min_value)
        end

        if @max_value
          validators << Validators::MaxValueValidator.new(@max_value)
        end
      end

      def default_error_messages
        super.merge(invalid: error_message(:integer, :invalid),
                    max_value: error_message(:integer, :max_value),
                    min_value: error_message(:integer, :min_value))
      end

      def to_object(value)
        value = super(value)

        if Validators.empty_value?(value)
          return nil
        end

        begin
          Integer(value.to_s)
        rescue ArgumentError
          raise ValidationError.new(error_messages[:invalid])
        end
      end
    end

    class FloatField < IntegerField
      def default_error_messages
        super.merge(invalid: error_message(:float, :invalid))
      end

      def to_object(value)
        if Validators.empty_value?(value)
          return nil
        end

        begin
          Utils.make_float(value.to_s)
        rescue ArgumentError
          raise ValidationError.new(error_messages[:invalid])
        end
      end
    end

    class BigDecimalField < Field
      def initialize(options={})
        @max_value = options.delete(:max_value)
        @min_value = options.delete(:min_value)
        @max_digits = options.delete(:max_digits)
        @max_decimal_places = options.delete(:max_decimal_places)

        if @max_digits && @max_decimal_places
          @max_whole_digits = @max_digits - @max_decimal_places
        end

        super(options)

        if @min_value
          validators << Validators::MinValueValidator.new(@min_value)
        end

        if @max_value
          validators << Validators::MaxValueValidator.new(@max_value)
        end
      end

      def default_error_messages
        super.merge(invalid: error_message(:big_decimal, :invalid),
                    max_value: error_message(:big_decimal, :max_value),
                    min_value: error_message(:big_decimal, :min_value),
                    max_digits: error_message(:big_decimal, :max_digits),
                    max_decimal_places: error_message(:big_decimal, :max_decimal_places),
                    max_whole_digits: error_message(:big_decimal, :max_whole_digits))
      end

      def to_object(value)
        if Validators.empty_value?(value)
          return nil
        end

        begin
          Utils.make_float(value)
          BigDecimal.new(value)
        rescue ArgumentError
          raise ValidationError.new(error_messages[:invalid])
        end
      end

      def validate(value)
        super(value)

        if Validators.empty_value?(value)
          return nil
        end

        if value.nan? || value.infinite?
          raise ValidationError.new(error_messages[:invalid])
        end

        sign, alldigits, _, whole_digits = value.split

        if @max_digits && alldigits.length > @max_digits
          msg = Utils.format_string(error_messages[:max_digits],
                                    max: @max_digits)
          raise ValidationError.new(msg)
        end

        decimals = alldigits.length - whole_digits

        if @max_decimal_places && decimals > @max_decimal_places
          msg = Utils.format_string(error_messages[:max_decimal_places],
                                    max: @max_decimal_places)
          raise ValidationError.new(msg)
        end

        if @max_whole_digits && whole_digits > @max_whole_digits
          msg = Utils.format_string(error_messages[:max_whole_digits],
                                    max: @max_whole_digits)
          raise ValidationError.new(msg)
        end

        value
      end
    end

    class DateField < CharField
      def initialize(input_formats, options={})
        super(options)
        @input_formats = input_formats
      end

      def default_error_messages
        super.merge(invalid: error_message(:date, :invalid))
      end

      def default_widget
        Widgets::DateInput
      end

      def to_object(value)
        if Validators.empty_value?(value)
          return nil
        end

        if value.is_a? DateTime
          return value.to_date
        end

        if value.is_a? Date
          return value
        end

        @input_formats.each do |format|
          begin
            return Date.strptime(value, format)
          rescue ArgumentError
          end
        end

        raise ValidationError.new(error_messages[:invalid])
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
          options[:error_messages][:invalid] = error_message
        end

        super(options)

        @regex = regex

        validators << Validators::RegexValidator.new(regex: regex)
      end
    end

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

    # TODO: rewrite
    class FileField < Field
      def initialize(options)
        @max_length = options.delete(:max_length)
        @allow_empty_file = options.delete(:allow_empty_file)
        super(options)
      end

      def default_error_messages
        super.merge(invalid: error_message(:file, :invalid),
                    missing: error_message(:file, :missing),
                    empty: error_message(:file, :empty),
                    max_length: error_message(:file, :max_length),
                    contradiction: error_message(:file, :contradiction))
      end

      def default_widget
        Widgets::ClearableFileInput
      end

      def to_object(data)
        if Validators.empty_value?(data)
          return nil
        end

        # UploadedFile objects should have name and size attributes.
        begin
          file_name = data.name
          file_size = data.size
        rescue NoMethodError
          raise ValidationError.new(error_messages[:invalid])
        end

        if @max_length && file_name.length > @max_length
          msg = Utils.format_string(error_messages[:max_length],
                                    max: @max_length,
                                    length: file_name.length)
          raise ValidationError.new(msg)
        end

        if Utils.blank_value?(file_name)
          raise ValidationError.new(error_messages[:invalid])
        end

        if !@allow_empty_file && !file_size
          raise ValidationError.new(error_messages[:empty])
        end

        data
      end

      def clean(data, initial = nil)
        # If the widget got contradictory inputs, we raise a validation error
        if data.object_id ==  Widgets::ClearableFileInput::FILE_INPUT_CONTRADICTION.object_id
          raise ValidationError.new(error_messages[:contradiction])
        end

        # False means the field value should be cleared; further validation is
        # not needed.
        if data == false
          unless @required
            return false
          end

          # If the field is required, clearing is not possible (the widget
          # shouldn't return false data in that case anyway). false is not
          # an 'empty_value'; if a false value makes it this far
          # it should be validated from here on out as nil (so it will be
          # caught by the required check).
          data = nil
        end

        if !data && initial
          initial
        else
          super(data)
        end
      end

      def bound_data(data, initial)
        if data.nil? || data.object_id == Widgets::ClearableFileInput::FILE_INPUT_CONTRADICTION.object_id
          initial
        else
          data
        end
      end
    end

    #class ImageField < FileField
    #end

    # URLField

    class BooleanField < Field
      def default_widget
        Widgets::CheckboxInput
      end

      def to_object(value)
        if value.kind_of?(String) && ['false', '0'].include?(value.downcase)
          value = false
        else
          value = Utils.make_bool(value)
        end

        value = super(value)

        if !value && required
          raise ValidationError.new(error_messages[:required])
        end

        value
      end
    end

    class NullBooleanField < BooleanField
      def default_widget
        Widgets::NullBooleanSelect
      end

      def to_object(value)
        case value
        when true, 'true', '1', 'on' then true
        when false, 'false', '0' then false
        else nil
        end
      end

      def validate(value)
      end
    end

    class ChoiceField < Field
      def initialize(choices=[], options={})
        options[:required] = options.fetch(:required, true)
        super(options)
        self.choices = choices
      end

      def initialize_copy(original)
        super(original)
        self.choices = original.choices.dup
      end

      def default_error_messages
        super.merge(invalid_choice: error_message(:choice, :invalid_choice))
      end

      def default_widget
        Widgets::Select
      end

      def choices
        @choices
      end

      def choices=(value)
        @choices = @widget.choices = value
      end

      def to_object(value)
        if Validators.empty_value?(value)
          ''
        else
          value.to_s
        end
      end

      def validate(value)
        super(value)

        unless !value || Validators.empty_value?(value) || valid_value?(value)
          msg = Utils.format_string(error_messages[:invalid_choice],
                                    value: value)
          raise ValidationError.new(msg)
        end
      end

      def valid_value?(value)
        @choices.each do |k, v|
          if v.is_a?(Array)
            # This is an optgroup, so look inside the group for options
            v.each do |k2, v2|
              return true if value == k2.to_s
            end
          elsif k.is_a?(Hash)
            # this is a hash valued choice list
            return true if value == k[:value].to_s
          else
            return true if value == k.to_s
          end
        end

        false
      end
    end

    class TypedChoiceField < ChoiceField
      def initialize(choices=[], options={})
        @coerce = options.delete(:coerce) || lambda{|val| val}
        @empty_value = options.fetch(:empty_value, '')
        options.delete(:empty_value)
        super(choices, options)
      end

      def to_object(value)
        value = super(value)
        original_validate(value)

        if value == @empty_value || Validators.empty_value?(value)
          return @empty_value
        end

        begin
          @coerce.call(value)
        rescue TypeError, ValidationError
          msg = Utils.format_string(error_messages[:invalid_choice],
                                    value: value)
          raise ValidationError.new(msg)
        end
      end

      alias_method :original_validate, :validate

      def validate(value)
      end
    end

    class MultipleChoiceField < ChoiceField
      def default_error_messages
        super.merge(invalid_choice: error_message(:multiple_choice, :invalid_choice),
                    invalid_list: error_message(:multiple_choice, :invalid_list))
      end

      def default_widget
        Widgets::SelectMultiple
      end

      def default_hidden_widget
        Widgets::MultipleHiddenInput
      end

      def to_object(value)
        if !value || Validators.empty_value?(value)
          []
        elsif !value.is_a?(Array)
          raise ValidationError.new(error_messages[:invalid_list])
        else
          value.map(&:to_s)
        end
      end

      def validate(value)
        if required && (!value || Validators.empty_value?(value))
          raise ValidationError.new(error_messages[:required])
        end

        value.each do |val|
          unless valid_value?(val)
            msg = Utils.format_string(error_messages[:invalid_choice],
                                      value: val)
            raise ValidationError.new(msg)
          end
        end
      end
    end

    # TypedMultipleChoiceField < MultipleChoiceField

    # TODO: tests
    class ComboField < Field
      def initialize(fields=[], *args)
        super(*args)
        fields.each {|f| f.required = false}
        @fields = fields
      end

      def clean(value)
        super(value)
        @fields.each {|f| value = f.clean(value)}
        value
      end
    end

    # MultiValueField
    # FilePathField
    # SplitDateTimeField

    class IPAddressField < CharField
      def default_error_messages
        super.merge(invalid: 'Enter a valid IPv4 address.')
      end

      def default_validators
        [Validators::ValidateIPV4Address]
      end
    end

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
