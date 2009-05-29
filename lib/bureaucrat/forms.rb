require 'bureaucrat/utils'
require 'bureaucrat/widgets'
require 'bureaucrat/fields'

module Bureaucrat; module Forms
  class BoundField
    include Utils

    attr_accessor :label

    def initialize(form, field, name)
      @form = form
      @field = field
      @name = name
      @html_name = form.add_prefix(name)
      @html_initial_name = form.add_initial_prefix(name)
      @label = @field.label || pretty_name(name)
      @help_text = @field.help_text || ''
    end

    def to_s
      @field.show_hidden_initial ? as_widget + as_hidden(nil, true) : as_widget
    end

    def errors
      @form.errors.fetch(@name, @form.error_class.new)
    end

    def as_widget(widget=nil, attrs=nil, only_initial=false)
      widget ||= @field.widget
      attrs ||= {}
      auto_id = self.auto_id
      attrs[:id] ||= auto_id if auto_id && !widget.attrs.key?(:id)

      if !@form.bound?
        data = @form.initial.fetch(@name, @field.initial)
        data = data.call if data.respond_to?(:call)
      else
        if @field.is_a?(Fields::FileField) && @data.nil?
          data = @form.initial.fetch(@name, @field.initial)
        else
          data = @data
        end
      end

      name = only_initial ? @html_initial_name : @html_name

      widget.render(name, data, attrs)
    end

    def as_text(attrs=nil, only_initial=false)
      as_widget(Widgets::TextInput.new, attrs, only_initial)
    end

    def as_textarea(attrs=nil, only_initial=false)
      as_widget(Widgets::Textarea.new, attrs, only_initial)
    end

    def as_hidden(attrs=nil, only_initial=false)
      as_widget(@field.hidden_widget, attrs, only_initial)
    end

    def data
      @field.widget.value_from_datahash(@form.data, @form.files, @html_name)
    end

    def label_tag(contents=nil, attrs=nil)
      contents ||= conditional_escape(@label)
      widget = @field.widget
      id_ = widget.attrs[:id] || self.auto_id

      if id_
        attrs = attrs ? flattatt(attrs) : ''
        contents = "<label for=\"#{widget.id_for_label(id_)}\"#{attrs}>#{contents}</label>"
      end

      mark_safe(contents)
    end

    def hidden?
      @field.widget.hidden?
    end

    def auto_id
      fauto_id = @form.auto_id
      fauto_id ? fauto_id % @html_name : ''
    end
  end

  class Form
    include Utils

    class << self
      attr_accessor :base_fields
      def field(name, field_obj)
        base_fields[name] = field_obj
      end

      # Copy data to the child class
      def inherited(c)
        super(c)
        c.base_fields = base_fields.dup
      end
    end

    @base_fields = OrderedHash.new

    attr_accessor :error_class, :auto_id

    def bound? ; @is_bound; end

    def initialize(data=nil, options={})
      @is_bound = !data.nil?
      @data = data || {}
      @files = options.fetch(:files, {})
      @auto_id = options.fetch(:auto_id, 'id_%s')
      @prefix = options[:prefix]
      @initial = options.fetch(:initial, {})
      @error_class = options.fetch(:error_class, ErrorList)
      @label_suffix = options.fetch(:label_suffix, ':')
      @empty_permitted = options.fetch(:empty_permitted, false)
      @errors = nil
      @changed_data = nil

      @fields = self.class.base_fields.dup
      @fields.each { |key, value| @fields[key] = value.dup }
    end

    def [](name)
      field = @fields[name] or return nil
      BoundField.new(self, field, name)
    end

    def errors
      full_clean if @errors.nil?
      @errors
    end

    def valid?
      @is_bound && (errors.nil? || errors.empty?)
    end

    def add_prefix(field_name)
      @prefix ? "#{prefix}-#{field_name}" : field_name
    end

    def add_initial_prefix(field_name)
      "initial-#{add_prefix(field_name)}"
    end

    def empty_permitted?
      @empty_permitted
    end

    def as_table
      html_output('<tr><th>%(label)s</th><td>%(errors)s%(field)s%(help_text)s</td></tr>',
                  '<tr><td colspan="2">%s</td></tr>', '</td></tr>',
                  '<br />%s', false)
    end

    def as_ul
      html_output('<li>%(errors)s%(label)s %(field)s%(help_text)s</li>',
                  '<li>%s</li>', '</li>', ' %s', false)
    end

    def as_p
      html_output('<p>%(label)s %(field)s%(help_text)s</p>',
                  '%s', '</p>', ' %s', true)
    end

    def non_field_errors
      errors.fetch(:__NON_FIELD_ERRORS, @error_class.new)
    end

    def full_clean
      @errors = ErrorHash.new

      return unless bound?

      @cleaned_data = {}

      return if empty_permitted? && !changed?

      @fields.each do |name, field|
          value = field.widget.value_from_datahash(@data, @files,
                                                   add_prefix(name))

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
            @cleaned_data.clear
          end
        end

      begin
        @cleaned_data = clean
      rescue ValidationError => e
        @errors[:__NON_FIELD_ERRORS] = e.messages
      end
      @cleaned_data = nil if @errors && !@errors.empty?
    end

    def clean
      @cleaned_data
    end

    def changed?
      changed_data && !changed_data.empty?
    end

    def changed_data
      if @changed_data.nil?
        @changed_data = []

        @fields.each do |name, field|
            prefixed_name = add_prefix(name)
            data_value = field.widget.value_from_datahash(@data, @files,
                                                          prefixed_name)
            if !field.show_hidden_initial
              initial_value = @initial.fetch(name, field.initial)
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

    def media
      @fields.values.inject(Widgets::Media.new) do |media, field|
          media + field.widget.media
        end
    end

    def multipart?
      @fields.any? {|f| f.widgetneeds_multipart_form?}
    end

    def hidden_fields
      @fields.select {|f| f.hidden?}
    end

    def visible_fields
      @fields.select {|f| !f.hidden?}
    end

  private
    def html_output(normal_row, error_row, row_ender, help_text_html,
                    errors_on_separate_row)
      top_errors = non_field_errors
      output, hidden_fields = [], []

      add_fields_output(output, hidden_fields, normal_row, error_row,
                        help_text_html, errors_on_separate_row)
      output = [error_row % top_errors] + output unless top_errors.empty?
      add_hidden_fields_output(output, hidden_fields, row_ender)

      mark_safe(output.join("\n"))
    end

    def add_fields_output(output, hidden_fields, normal_row, error_row,
                          help_text_html, errors_on_separate_row)
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
              label = bf.label_tag(label)
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

    def add_hidden_fields_output(output, hidden_fields, row_ender)
      unless hidden_fields.empty?
        str_hidden = hidden_fields.join('')

        unless output.empty?
          last_row = output[-1]
          unless last_row.endswith(row_ender)
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

    def raw_value(fieldname)
      field = @fields.fetch(fieldname)
      prefix = add_prefix(fieldname)
      field.widget.value_from_datahash(@data, @files, prefix)
    end

  end
end; end
