require 'bureaucrat/utils'
require 'bureaucrat/validation'
require 'bureaucrat/widgets'
require 'bureaucrat/fields'

module Bureaucrat
  module Forms

    # Instances of +BoundField+ represent a fields with associated data.
    # +BoundField+s are used internally by the +Form+ class.
    class BoundField
      include Utils

      # Field label text
      attr_accessor :label

      # Instantiates a new +BoundField+ associated to +form+'s field +field+
      # named +name+.
      def initialize(form, field, name)
        @form = form
        @field = field
        @name = name
        @html_name = form.add_prefix(name).to_sym
        @html_initial_name = form.add_initial_prefix(name).to_sym
        @label = @field.label || pretty_name(name)
        @help_text = @field.help_text || ''
      end

      # Renders the field.
      def to_s
        @field.show_hidden_initial ? as_widget + as_hidden(nil, true) : as_widget
      end

      # Errors for this field.
      def errors
        @form.errors.fetch(@name, @form.error_class.new)
      end

      # Renders this field with the option of using alternate widgets
      # and attributes.
      def as_widget(widget=nil, attrs=nil, only_initial=false)
        widget ||= @field.widget
        attrs ||= {}
        auto_id = self.auto_id
        attrs[:id] ||= auto_id if auto_id && !widget.attrs.key?(:id)

        if !@form.bound?
          data = @form.initial.fetch(@name.to_sym, @field.initial)
          data = data.call if data.respond_to?(:call)
        else
          if @field.is_a?(Fields::FileField) && @data.nil?
            data = @form.initial.fetch(@name, @field.initial)
          else
            data = self.data
          end
        end

        name = only_initial ? @html_initial_name : @html_name
        widget.render(name.to_s, data, attrs)
      end

      # Renders this field as a text input.
      def as_text(attrs=nil, only_initial=false)
        as_widget(Widgets::TextInput.new, attrs, only_initial)
      end

      # Renders this field as a text area.
      def as_textarea(attrs=nil, only_initial=false)
        as_widget(Widgets::Textarea.new, attrs, only_initial)
      end

      # Renders this field as hidden.
      def as_hidden(attrs=nil, only_initial=false)
        as_widget(@field.hidden_widget, attrs, only_initial)
      end

      # The data associated to this field.
      def data
        @field.widget.value_from_datahash(@form.data, @form.files, @html_name)
      end

      # Renders the label tag for this field.
      def label_tag(contents=nil, attrs=nil)
        contents ||= conditional_escape(@label)
        widget = @field.widget
        id_ = widget.attrs[:id] || self.auto_id

        if id_
          attrs = attrs ? flatatt(attrs) : ''
          contents = "<label for=\"#{Widgets::Widget.id_for_label(id_)}\"#{attrs}>#{contents}</label>"
        end

        mark_safe(contents)
      end

      # true if the widget for this field is of the hidden kind.
      def hidden?
        @field.widget.hidden?
      end

      # Generates the id for this field.
      def auto_id
        fauto_id = @form.auto_id
        fauto_id ? fauto_id % @html_name : ''
      end
    end

    # Base class for forms. Forms are a collection of fields with data that
    # knows how to render and validate itself.
    #
    # === Bound vs Unbound forms
    # A form is 'bound' if it was initialized with a set of data for its fields,
    # otherwise it is 'unbound'. Only bound forms can be validated. Unbound
    # forms always respond with false to +valid?+ and return an empty
    # list of errors.

    class Form
      include Utils
      include Validation

      class << self
        # Fields associated to the form class (an instance may add or remove
        # fields from itself)
        attr_accessor :base_fields

        # Fields associated to the form class
        def base_fields
          @base_fields ||= Utils::OrderedHash.new
        end

        # Declares a named field to be used on this form.
        def field(name, field_obj)
          base_fields[name] = field_obj
        end

        # Copy data to the child class
        def inherited(c)
          super(c)
          c.base_fields = base_fields.dup
        end
      end

      # Error class for this form
      attr_accessor :error_class
      # Format string for field id generator
      attr_accessor :auto_id
      # Hash of {field_name => initial_value}
      attr_accessor :initial
      # Data associated to this form {field_name => value}
      attr_accessor :data
      # TODO: complete implementation
      attr_accessor :files
      # Validated and cleaned data
      attr_accessor :cleaned_data
      # Fields belonging to this form
      attr_accessor :fields

      # Checks if this form was initialized with data.
      def bound? ; @is_bound; end

      # Instantiates a new form bound to the passed data (or unbound if data is nil)
      #
      # +data+ is a hash of {field_name => value} for this form to be bound
      # (will be unbound if nil)
      #
      # Possible options are:
      #   :prefix          prefix that will be used for fields when rendered
      #   :auto_id         format string that will be used when generating
      #                    field ids (default: 'id_%s')
      #   :initial         hash of {field_name => default_value}
      #                    (doesn't make a form bound)
      #   :error_class     class used to represent errors (default: ErrorList)
      #   :label_suffix    suffix string that will be appended to labels' text
      #                    (default: ':')
      #   :empty_permitted boolean value that specifies if this form is valid
      #                    when empty

      def initialize(data=nil, options={})
        @is_bound = !data.nil?
        @data = {}
        data.each {|k, v| @data[k.to_sym] = @data[k] = v} if data
        @files = options.fetch(:files, {})
        @auto_id = options.fetch(:auto_id, 'id_%s')
        @prefix = options[:prefix]
        @initial = {}
        options.fetch(:initial, {}).each {|k, v| @initial[k.to_sym] = @initial[k] = v}
        @error_class = options.fetch(:error_class, Fields::ErrorList)
        @label_suffix = options.fetch(:label_suffix, ':')
        @empty_permitted = options.fetch(:empty_permitted, false)
        @errors = nil
        @changed_data = nil

        @fields = self.class.base_fields.dup
        @fields.each { |key, value| @fields[key] = value.dup }
      end

      # Renders the form +as_table+
      def to_s
        as_table
      end

      # Access a named field
      def [](name)
        field = @fields[name] or return nil
        BoundField.new(self, field, name)
      end

      # Errors for this forms (runs validations)
      def errors
        full_clean if @errors.nil?
        @errors
      end

      # Perform validation and returns true if there are no errors
      def valid?
        @is_bound && (errors.nil? || errors.empty?)
      end

      # Generates a prefix for field named +field_name+
      def add_prefix(field_name)
        @prefix ? :"#{@prefix}-#{field_name}" : field_name
      end

      # Generates an initial-prefix for field named +field_name+
      def add_initial_prefix(field_name)
        "initial-#{add_prefix(field_name)}"
      end

      # true if the form is valid when empty
      def empty_permitted?
        @empty_permitted
      end

      # Renders this form's fields as rows to be used on a table
      def as_table
        html_output('<tr><th>%(label)s</th><td>%(errors)s%(field)s%(help_text)s</td></tr>',
                    '<tr><td colspan="2">%s</td></tr>', '</td></tr>',
                    '<br />%s', false)
      end

      # Renders this form's fields as li tags to be used on a list
      def as_ul
        html_output('<li>%(errors)s%(label)s %(field)s%(help_text)s</li>',
                    '<li>%s</li>', '</li>', ' %s', false)
      end

      # Renders this form's fields as paragraph tags
      def as_p
        html_output('<p>%(label)s %(field)s%(help_text)s</p>',
                    '%s', '</p>', ' %s', true)
      end

      # Returns the list of errors that aren't associated to a specific field
      def non_field_errors
        errors.fetch(:__NON_FIELD_ERRORS, @error_class.new)
      end

      # Runs all the validations for this form. If the form is invalid
      # the list of errors is populated, if it is valid, cleaned_data is
      # populated
      def full_clean
        @errors = Fields::ErrorHash.new

        return unless bound?

        @cleaned_data = {}

        return if empty_permitted? && !changed?

        @fields.each do |name, field|
            value = field.widget.value_from_datahash(@data, @files,
                                                     add_prefix(name))

            begin
              if field.is_a?(Fields::FileField)
                initial = @initial.fetch(name.to_sym, field.initial)
                @cleaned_data[name] = field.clean(value, initial)
              else
                @cleaned_data[name] = field.clean(value)
              end

              clean_method = 'clean_%s' % name
              @cleaned_data[name] = send(clean_method) if respond_to?(clean_method)
            rescue Fields::FieldValidationError => e
              @errors[name] = e.messages
              @cleaned_data.clear
            end
          end

        begin
          @cleaned_data = clean
        rescue Fields::FieldValidationError => e
          @errors[:__NON_FIELD_ERRORS] = e.messages
        end
        @cleaned_data = nil if @errors && !@errors.empty?
      end

      # Performs the last step of validations on the form, override in subclasses
      # to customize behaviour.
      def clean
        @cleaned_data
      end

      # true if the form has data that isn't equal to its initial data
      def changed?
        changed_data && !changed_data.empty?
      end

      # List names for fields that have changed data
      def changed_data
        if @changed_data.nil?
          @changed_data = []

          @fields.each do |name, field|
              prefixed_name = add_prefix(name)
              data_value = field.widget.value_from_datahash(@data, @files,
                                                            prefixed_name)
              if !field.show_hidden_initial
                initial_value = @initial.fetch(name.to_sym, field.initial)
              else
                initial_prefixed_name = add_initial_prefix(name)
                hidden_widget = field.hidden_widget.new
                initial_value = hidden_widget.value_from_datahash(@data, @files,
                                                                  initial_prefixed_name)
              end

              @changed_data << name if
                field.widget.has_changed?(initial_value, data_value)
            end
        end

        @changed_data
      end

      # List of media associated to this form
      def media
        @fields.values.inject(Widgets::Media.new) do |media, field|
            media + field.widget.media
          end
      end

      # true if this form contains fields that require the form to be
      # multipart
      def multipart?
        @fields.any? {|f| f.widgetneeds_multipart_form?}
      end

      # List of hidden fields.
      def hidden_fields
        @fields.select {|f| f.hidden?}
      end

      # List of visible fields
      def visible_fields
        @fields.select {|f| !f.hidden?}
      end

      # Attributes for labels, override in subclasses to customize behaviour
      def label_attributes(name, field)
        {}
      end

    private
      # Helper method to render all the form fields. This is called by
      # +as_table+, +as_p+, and +as_ul+ and you probably want to call it
      # when writting custom renderers.
      #
      # TODO: document parameters
      def html_output(normal_row, error_row, row_ender, help_text_html,
                      errors_on_separate_row)
        top_errors = non_field_errors
        output, hidden_fields = [], []

        add_fields_output(output, hidden_fields, normal_row, error_row,
                          help_text_html, errors_on_separate_row, top_errors)
        output = [error_row % top_errors] + output unless top_errors.empty?
        add_hidden_fields_output(output, hidden_fields, row_ender)

        mark_safe(output.join("\n"))
      end

      def add_fields_output(output, hidden_fields, normal_row, error_row,
                            help_text_html, errors_on_separate_row,
                            top_errors) # :nodoc:
        @fields.each do |name, field|
            bf = BoundField.new(self, field, name)
            bf_errors = @error_class.new(bf.errors.map {|e| conditional_escape(e)})
            if bf.hidden?
              top_errors += bf_errors.map do |e|
                "(Hidden field #{name}) #{e.to_s}"
              end unless bf_errors.empty?
              hidden_fields << bf.to_s
            else
              output << error_row % bf_errors if
                errors_on_separate_row && !bf_errors.empty?

              label = ''
              unless bf.label.nil? || bf.label.empty?
                label = conditional_escape(bf.label)
                label += @label_suffix if @label_suffix && label[-1,1] !~ /[:?.!]/
                label = bf.label_tag(label, label_attributes(name, field))
              end

              help_text = field.help_text.empty? ? '' : help_text_html % field.help_text
              vars = {
                :errors => bf_errors, :label => label,
                :field => bf, :help_text => help_text
              }
              output << format_string(normal_row, vars)
            end
          end
      end

      def add_hidden_fields_output(output, hidden_fields, row_ender) # :nodoc:
        unless hidden_fields.empty?
          str_hidden = hidden_fields.join('')

          unless output.empty?
            last_row = output[-1]
            if last_row !~ /#{row_ender}$/
              vars = {
                :errors => '', :label => '', :field => '', :help_text => ''
              }
              last_row = format_string(normal_row, vars)
              output << last_row
            end
            output[-1] = last_row[0...-row_ender.length] + str_hidden + row_ender
          else
            output << str_hidden
          end
        end
      end

      # Returns the value for the field name +field_name+ from the associated
      # data
      def raw_value(fieldname)
        field = @fields.fetch(fieldname)
        prefix = add_prefix(fieldname)
        field.widget.value_from_datahash(@data, @files, prefix)
      end

    end

  end
end
