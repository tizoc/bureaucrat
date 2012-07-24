require 'bureaucrat/utils'
require 'bureaucrat/widgets/text_input'

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
      attr_accessor :css_class, :required, :initial, :widget, :hidden_widget, :show_hidden_initial, :help_text, :validators, :form_name, :name

      def initialize(options={})
        @required = options.fetch(:required, true)
        @show_hidden_initial = options.fetch(:show_hidden_initial, false)
        @given_label = options[:label]
        @initial = options[:initial]
        @help_text = options.fetch(:help_text, '')
        @widget = options.fetch(:widget, default_widget)

        @css_class = options[:css_class]
        @id = options[:id]

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

      def error_message(scope, error, params={})
        message = I18n.t("bureaucrat.#{form_name}.#{name}.errors.#{error}", default: I18n.t("bureaucrat.default_errors.fields.#{scope}.#{error}"))
        Utils.format_string(message, params)
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
  end
end
