require 'active_support/core_ext/string'
require 'bureaucrat/fields/bound_field'
require 'bureaucrat/fields/field'
require 'bureaucrat/utils'

module Bureaucrat
  class Form
    include Utils

    # Fields associated to the form class
    def self.base_fields
      @base_fields ||= {}
    end

    # Declares a named field to be used on this form.
    def self.field(name, field_obj)
      field_obj.form_name = self.to_s.underscore
      field_obj.name = name
      base_fields[name] = field_obj
    end

    # Copy data to the child class
    def self.inherited(c)
      super(c)
      c.instance_variable_set(:@base_fields, base_fields.dup)
    end

    # Error object class for this form
    attr_accessor :error_class
    # Required class for this form
    attr_accessor :required_css_class
    # Required class for this form
    attr_accessor :error_css_class
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
      @data = StringAccessHash.new(data || {})
      @files = options.fetch(:files, {})
      @auto_id = options.fetch(:auto_id, 'id_%s')
      @prefix = options[:prefix]
      @initial = StringAccessHash.new(options.fetch(:initial, {}))
      @error_class = options.fetch(:error_class, Fields::ErrorList)
      @label_suffix = options.fetch(:label_suffix, ':')
      @empty_permitted = options.fetch(:empty_permitted, false)
      @errors = nil
      @changed_data = nil

      @fields = self.class.base_fields.dup
      @fields.each { |key, value| @fields[key] = value.dup }
    end

    # Iterates over the fields
    def each
      @fields.each do |name, field|
        yield Fields::BoundField.new(self, field, name)
      end
    end

    # Access a named field
    def [](name)
      field = @fields[name] or return nil
      Fields::BoundField.new(self, field, name)
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
      @prefix ? "#{@prefix}-#{field_name}" : field_name
    end

    # Generates an initial-prefix for field named +field_name+
    def add_initial_prefix(field_name)
      "initial-#{add_prefix(field_name)}"
    end

    # true if the form is valid when empty
    def empty_permitted?
      @empty_permitted
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

      @cleaned_data = StringAccessHash.new

      return if empty_permitted? && !changed?
      @fields.each do |name, field|
        value = field.widget.
          value_from_formdata(@data, add_prefix(name))

        begin
          if field.is_a?(Fields::FileField)
            initial = @initial.fetch(name, field.initial)
            @cleaned_data[name] = field.clean(value, initial)
          else
            @cleaned_data[name] = field.clean(value)
          end

          clean_method = 'clean_%s' % name
          @cleaned_data[name] = send(clean_method) if respond_to?(clean_method)
        rescue ValidationError => e
          @errors[name] = e.messages
          @cleaned_data.delete(name)
        end
      end

      begin
        @cleaned_data = clean
      rescue ValidationError => e
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
          data_value = field.widget.
            value_from_formdata(@data, prefixed_name)

          if !field.show_hidden_initial
            initial_value = @initial.fetch(name, field.initial)
          else
            initial_prefixed_name = add_initial_prefix(name)
            hidden_widget = field.hidden_widget.new
            initial_value = hidden_widget.
              value_from_formdata(@data, initial_prefixed_name)
          end

          @changed_data << name if
          field.widget.has_changed?(initial_value, data_value)
        end
      end

      @changed_data
    end

    # true if this form contains fields that require the form to be
    # multipart
    def multipart?
      @fields.any? {|f| f.widget.multipart_form?}
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

    # Populates the passed object's attributes with data from the fields
    def populate_object(object)
      @fields.each do |name, field|
        field.populate_object(object, name, @cleaned_data[name])
      end
    end

    private

    # Returns the value for the field name +field_name+ from the associated
    # data
    def raw_value(fieldname)
      field = @fields.fetch(fieldname)
      prefix = add_prefix(fieldname)
      field.widget.value_from_formdata(@data, prefix)
    end

  end
end
