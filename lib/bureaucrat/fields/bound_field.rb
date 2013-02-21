require 'bureaucrat/utils'

module Bureaucrat
  module Fields
    class BoundField
      include Utils

      # Field label text
      attr_accessor :label, :form, :field, :name, :html_name, :html_initial_name, :help_text

      # Instantiates a new +BoundField+ associated to +form+'s field +field+
      # named +name+.
      def initialize(form, field, name)
        @form = form
        @field = field
        @name = name
        @html_name = form.add_prefix(name)
        @html_initial_name = form.add_initial_prefix(name)
        @label = @field.label
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
          data = @form.initial.fetch(@name, @field.initial)
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

      def form_data
        @field.widget.form_value(@form.data, @html_name)
      end

      # The data associated to this field.
      def data
        @field.widget.value_from_formdata(@form.data, @html_name)
      end

      def value
        # Returns the value for this BoundField, using the initial value if
        # the form is not bound or the data otherwise.

        if form.bound?
          val = field.bound_data(data, form.initial.fetch(name, field.initial))
        else
          val = form.initial.fetch(name, field.initial)
          if val.respond_to?(:call)
            val = val.call
          end
        end

        field.prepare_value(val)
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

      def css_classes(extra_classes = nil)
        # Returns a string of space-separated CSS classes for this field.

        if extra_classes.respond_to?(:split)
          extra_classes = extra_classes.split
        end

        extra_classes = Set.new(extra_classes)

        if !errors.empty? && !Utils.blank_value?(form.error_css_class)
          extra_classes << form.error_css_class
        end

        if field.required && !Utils.blank_value?(form.required_css_class)
          extra_classes << form.required_css_class
        end

        extra_classes.to_a.join(' ')
      end

      # true if the widget for this field is of the hidden kind.
      def hidden?
        @field.widget.hidden?
      end

      def pass_thru?
        @field.widget.pass_thru?
      end

      # Generates the id for this field.
      def auto_id
        fauto_id = @form.auto_id
        fauto_id ? fauto_id % @html_name : ''
      end
    end
  end
end
