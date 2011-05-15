require 'uri'

module Bureaucrat
  module Widgets
    # Base class for widgets
    class Widget
      include Utils

      attr_accessor :is_required
      attr_reader :attrs

      def initialize(attrs = nil)
        @attrs = attrs.nil? ? {} : attrs.dup
      end

      def initialize_copy(original)
        super(original)
        @attrs = original.attrs.dup
      end

      def render(name, value, attrs = nil)
        raise NotImplementedError
      end

      def build_attrs(extra_attrs = nil, options = {})
        attrs = @attrs.merge(options)
        attrs.update(extra_attrs) if extra_attrs
        attrs
      end

      def value_from_formdata(data, files, name)
        data[name]
      end

      def self.id_for_label(id_)
        id_
      end

      def has_changed?(initial, data)
        data_value = data || ''
        initial_value = initial || ''
        initial_value != data_value
      end

      def needs_multipart?
        false
      end

      def hidden?
        false
      end
    end

    # Base class for input widgets
    class Input < Widget
      def render(name, value, attrs=nil)
        value ||= ''
        final_attrs = build_attrs(attrs,
                                  :type => input_type.to_s,
                                  :name => name.to_s)
        final_attrs[:value] = value.to_s unless value == ''
        mark_safe("<input#{flatatt(final_attrs)} />")
      end

      def input_type
        nil
      end
    end

    # Class for text inputs
    class TextInput < Input
      def input_type
        'text'
      end
    end

    # Class for password inputs
    class PasswordInput < Input
      def initialize(attrs = nil, render_value = false)
        super(attrs)
        @render_value = render_value
      end

      def input_type
        'password'
      end

      def render(name, value, attrs=nil)
        value = nil unless @render_value
        super(name, value, attrs)
      end
    end

    # Class for hidden inputs
    class HiddenInput < Input
      def input_type
        'hidden'
      end

      def hidden?
        true
      end
    end

    class MultipleHiddenInput < HiddenInput
      # Used by choice fields
      attr_accessor :choices

      def initialize(attrs=nil, choices=[])
        super(attrs)
        # choices can be any enumerable
        @choices = choices
      end

      def render(name, value, attrs=nil, choices=[])
        value ||= []
        final_attrs = build_attrs(attrs, :type => input_type.to_s,
                                  :name => name)


        id = final_attrs[:id]
        inputs = []

        value.each.with_index do |v, i|
          input_attrs = final_attrs.merge(:value => v.to_s)

          if id
            input_attrs[:id] = "#{id}_#{i}"
          end

          inputs << "<input#{flatatt(input_attrs)} />"
        end

        mark_safe(inputs.join("\n"))
      end

      def value_from_formdata(data, files, name)
        #if data.is_a?(MultiValueDict) || data.is_a?(MergeDict)
        #  data.getlist(name)
        #else
        #  data[name]
        #end
        data[name]
      end
    end

    class FileInput < Input
      def render(name, value, attrs=nil)
        super(name, nil, attrs)
      end

      def value_from_formdata(data, files, name)
        files[name]
      end

      def has_changed?(initial, data)
        data.nil?
      end

      def input_type
        'file'
      end

      def needs_multipart?
        true
      end
    end

    class Textarea < Widget
      def initialize(attrs=nil)
        # The 'rows' and 'cols' attributes are required for HTML correctness.
        default_attrs = {:cols => '40', :rows => '10'}
        default_attrs.merge!(attrs) if attrs

        super(default_attrs)
      end

      def render(name, value, attrs=nil)
        value ||= ''
        final_attrs = build_attrs(attrs, :name => name)
        mark_safe("<textarea#{flatatt(final_attrs)}>#{conditional_escape(value.to_s)}</textarea>")
      end
    end

    # DateInput
    # DateTimeInput
    # TimeInput

    class CheckboxInput < Widget
      def initialize(attrs=nil, check_test=nil)
        super(attrs)
        @check_test = check_test || lambda {|v| make_bool(v)}
      end

      def render(name, value, attrs=nil)
        final_attrs = build_attrs(attrs, :type => 'checkbox', :name => name.to_s)

        # FIXME: this is horrible, shouldn't just rescue everything
        result = @check_test.call(value) rescue false

        if result
          final_attrs[:checked] = 'checked'
        end

        unless ['', true, false, nil].include?(value)
          final_attrs[:value] = value.to_s
        end

        mark_safe("<input#{flatatt(final_attrs)} />")
      end

      def value_from_formdata(data, files, name)
        if data.include?(name)
          value = data[name]

          if value.is_a?(String)
            case value.downcase
            when 'true' then true
            when 'false' then false
            else value
            end
          else
            value
          end
        else
          false
        end
      end

      def has_changed(initial, data)
        make_bool(initial) != make_bool(data)
      end
    end

    class Select < Widget
      attr_accessor :choices

      def initialize(attrs=nil, choices=[])
        super(attrs)
        @choices = choices.collect
      end

      def render(name, value, attrs=nil, choices=[])
        value = '' if value.nil?
        final_attrs = build_attrs(attrs, :name => name)
        output = ["<select#{flatatt(final_attrs)}>"]
        options = render_options(choices, [value])
        output << options if options && !options.empty?
        output << '</select>'
        mark_safe(output.join("\n"))
      end

      def render_options(choices, selected_choices)
        selected_choices = selected_choices.map(&:to_s).uniq
        output = []
        (@choices.to_a + choices.to_a).each do |option_value, option_label|
            option_label ||= option_value
            if option_label.is_a?(Array)
              output << '<optgroup label="%s">' % escape(option_value.to_s)
              option_label.each do |option|
                val, label = option
                output << render_option(val, label, selected_choices)
              end
              output << '</optgroup>'
            else
              output << render_option(option_value, option_label,
                                      selected_choices)
            end
          end
        output.join("\n")
      end

      def render_option(option_attributes, option_label, selected_choices)
        unless option_attributes.is_a?(Hash)
          option_attributes = { :value => option_attributes.to_s }
        end

        if selected_choices.include?(option_attributes[:value])
          option_attributes[:selected] = "selected"
        end

        attributes = []

        option_attributes.each_pair do |attr_name, attr_value|
          attributes << %Q[#{attr_name.to_s}="#{escape(attr_value.to_s)}"]
        end

        "<option #{attributes.join(' ')}>#{conditional_escape(option_label.to_s)}</option>"
      end
    end

    class NullBooleanSelect < Select
      def initialize(attrs=nil)
        choices = [['1', 'Unknown'], ['2', 'Yes'], ['3', 'No']]
        super(attrs, choices)
      end

      def render(name, value, attrs=nil, choices=[])
        value = case value
                when true, '2' then '2'
                when false, '3' then '3'
                else '1'
                end
        super(name, value, attrs, choices)
      end

      def value_from_formdata(data, files, name)
        case data[name]
        when '2', true, 'true' then true
        when '3', false, 'false' then false
        else nil
        end
      end

      def has_changed?(initial, data)
        unless initial.nil?
          initial = make_bool(initial)
        end

        unless data.nil?
          data = make_bool(data)
        end

        initial != data
      end
    end

    class SelectMultiple < Select
      def render(name, value, attrs=nil, choices=[])
        value = [] if value.nil?
        final_attrs = build_attrs(attrs, :name => name)
        output = ["<select multiple=\"multiple\"#{flatatt(final_attrs)}>"]
        options = render_options(choices, value)
        output << options if options && !options.empty?
        output << '</select>'
        mark_safe(output.join("\n"))
      end

      def value_from_formdata(data, files, name)
        #if data.is_a?(MultiValueDict) || data.is_a?(MergeDict)
        #  data.getlist(name)
        #else
        #  data[name]
        #end
        data[name]
      end

      def has_changed?(initial, data)
        initial = [] if initial.nil?
        data = [] if data.nil?

        if initial.length != data.length
          return true
        end

        Set.new(initial.map(&:to_s)) != Set.new(data.map(&:to_s))
      end
    end

    class RadioInput
      include Utils

      def initialize(name, value, attrs, choice, index)
        @name = name
        @value = value
        @attrs = attrs
        @choice_value = choice[0].to_s
        @choice_label = choice[1].to_s
        @index = index
      end

      def to_s
        label_for = @attrs.include?(:id) ? " for=\"#{@attrs[:id]}_#{@index}\"" : ''
        choice_label = conditional_escape(@choice_label.to_s)
        mark_safe("<label#{label_for}>#{tag} #{choice_label}</label>")
      end

      def checked?
        @value == @choice_value
      end

      def tag
        @attrs[:id] = "#{@attrs[:id]}_#{@index}" if @attrs.include?(:id)
        final_attrs = @attrs.merge(:type => 'radio', :name => @name,
                                   :value => @choice_value)
        final_attrs[:checked] = 'checked' if checked?
        mark_safe("<input#{flatatt(final_attrs)} />")
      end
    end

    class RadioFieldRenderer
      include Utils

      def initialize(name, value, attrs, choices)
        @name = name
        @value = value
        @attrs = attrs
        @choices = choices
      end

      def each
        @choices.each_with_index do |choice, i|
          yield RadioInput.new(@name, @value, @attrs.dup, choice, i)
        end
      end

      def [](idx)
        choice = @choices[idx]
        RadioInput.new(@name, @value, @attrs.dup, choice, idx)
      end

      def to_s
        render
      end

      def render
        list = []
        each {|radio| list << "<li>#{radio}</li>"}
        mark_safe("<ul>\n#{list.join("\n")}\n</ul>")
      end
    end

    class RadioSelect < Select
      def self.id_for_label(id_)
        id_.empty? ? id_ : id_ + '_0'
      end

      def renderer
        RadioFieldRenderer
      end

      def initialize(*args)
        options = args.last.is_a?(Hash) ? args.last : {}
        @renderer = options.fetch(:renderer, renderer)
        super
      end

      def get_renderer(name, value, attrs=nil, choices=[])
        value ||= ''
        str_value = value.to_s
        final_attrs = build_attrs(attrs)
        choices = @choices + choices
        @renderer.new(name, str_value, final_attrs, choices)
      end

      def render(name, value, attrs=nil, choices=[])
        get_renderer(name, value, attrs, choices).render
      end
    end

    class CheckboxSelectMultiple < SelectMultiple
      def self.id_for_label(id_)
        id_.empty? ? id_ : id_ + '_0'
      end

      def render(name, values, attrs=nil, choices=[])
        values ||= []
        has_id = attrs && attrs.include?(:id)
        final_attrs = build_attrs(attrs, :name => name)
        output = ['<ul>']
        str_values = {}
        values.each {|val| str_values[(val.to_s)] = true}

        (@choices + choices).each_with_index do |opt_pair, i|
            opt_val, opt_label = opt_pair
            if has_id
              final_attrs[:id] = "#{attrs[:id]}_#{i}"
              label_for = " for=\"#{final_attrs[:id]}\""
            else
              label_for = ''
            end

            check_test = lambda{|value| str_values[value]}
            cb = CheckboxInput.new(final_attrs, check_test)
            opt_val = opt_val.to_s
            rendered_cb = cb.render(name, opt_val)
            opt_label = conditional_escape(opt_label.to_s)
            output << "<li><label#{label_for}>#{rendered_cb} #{opt_label}</label></li>"
          end
        output << '</ul>'
        mark_safe(output.join("\n"))
      end
    end

    # TODO: MultiWidget < Widget
    # TODO: SplitDateTimeWidget < MultiWidget
    # TODO: SplitHiddenDateTimeWidget < SplitDateTimeWidget

  end
end
