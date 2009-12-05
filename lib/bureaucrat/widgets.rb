require 'uri'

require 'bureaucrat/utils'

module Bureaucrat
  module Widgets
    class Media
      include Utils

      MEDIA_TYPES = [:css, :js]
      DEFAULT_MEDIA_PATH = 'http://localhost'

      attr_accessor :media_path

      def initialize(media_attrs={})
        self.media_path = media_attrs.delete(:media_path) || DEFAULT_MEDIA_PATH
        media_attrs = media_attrs.to_hash if media_attrs.is_a?(Media)
        @css = {}
        @js = []

        MEDIA_TYPES.each do |name|
            data = media_attrs[name]
            add_type(name, data) if data
          end
      end

      def to_s
        render
      end

      def to_hash
        hash = {}
        MEDIA_TYPES.each {|name| hash[name] = instance_variable_get("@#{name}")}
        hash
      end

      def render
        mark_safe(MEDIA_TYPES.map do |name|
                    render_type(name)
                  end.inject(&:+).join("\n"))
      end

      def render_type(type)
        send("render_#{type}")
      end

      def render_js
        @js.map do |path|
            "<script type=\"text/javascript\" src=\"#{absolute_path(path)}\"></script>"
          end
      end

      def render_css
        fragments = @css.keys.sort.map do |medium|
            @css[medium].map do |path|
              "<link href=\"#{absolute_path(path)}\" type=\"text/css\" media=\"#{medium}\" rel=\"stylesheet\" />"
            end
          end
        fragments.empty? ? fragments : fragments.inject(&:+)
      end

      def absolute_path(path)
        path =~ /^(\/|https?:\/\/)/ ? path : URI.join(media_path, path)
      end

      def [](name)
        raise IndexError("Unknown media type '#{name}'") unless
          MEDIA_TYPES.include?(name)
        Media.new(name => instance_variable_get("@{name}"))
      end

      def add_type(type, data)
        send("add_#{type}", data)
      end

      def add_js(data)
        @js += data.select {|path| !@js.include?(path)}
      end

      def add_css(data)
        data.each do |medium, paths|
            @css[medium] ||= []
            css = @css[medium]
            css.concat(paths.select {|path| !css.include?(path)})
          end
      end

      def +(other)
        combined = Media.new
        MEDIA_TYPES.each do |name|
            combined.add_type(name, instance_variable_get("@#{name}"))
            combined.add_type(name, other.instance_variable_get("@#{name}"))
          end
        combined
      end
    end

    class Widget
      include Utils

      class << self
        attr_accessor :needs_multipart_form, :is_hidden

        def inherited(c)
          super(c)
          c.is_hidden = is_hidden
          c.needs_multipart_form = needs_multipart_form
        end
      end

      self.needs_multipart_form = false
      self.is_hidden = false

      attr_reader :attrs

      def initialize(attrs=nil)
        @attrs = attrs.nil? ? {} : attrs.dup
      end

      def initialize_copy(original)
        super(original)
        @attrs = original.attrs.dup
      end

      def render(name, value, attrs=nil)
        raise NotImplementedError
      end

      def build_attrs(extra_attrs=nil, options={})
        attrs = @attrs.merge(options)
        attrs.update(extra_attrs) if extra_attrs
        attrs
      end

      def value_from_datahash(data, files, name)
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

      def hidden?
        self.class.is_hidden
      end

      def media
        Media.new
      end
    end

    class Input < Widget
      class << self
        attr_accessor :input_type

        # Copy data to the child class
        def inherited(c)
          super(c)
          c.input_type = input_type.dup if input_type
        end
      end

      self.is_hidden = false
      self.input_type = nil

      def render(name, value, attrs=nil)
        value ||= ''
        final_attrs = build_attrs(attrs,
                                  :type => self.class.input_type.to_s,
                                  :name => name.to_s)
        final_attrs[:value] = value.to_s unless value == ''
        mark_safe("<input#{flatatt(final_attrs)} />")
      end
    end

    class TextInput < Input
      self.input_type = 'text'
    end

    class PasswordInput < Input
      self.input_type = 'password'

      def initialize(attrs=nil, render_value=true)
        super(attrs)
        @render_value = render_value
      end

      def render(name, value, attrs=nil)
        value = nil unless @render_value
        super(name, value, attrs)
      end
    end

    class HiddenInput < Input
      self.input_type = 'hidden'
      self.is_hidden = true
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
        final_attrs = build_attrs(attrs, :type => self.class.input_type,
                                  :name => name)
        mark_safe(value.map do |v|
                    rattrs = {:value => v.to_s}.merge(final_attrs)
                    "<input#{flatatt(rattrs)} />"
                  end.join("\n"))
      end

      def value_from_datahash(data, files, name)
        #if data.is_a?(MultiValueDict) || data.is_a?(MergeDict)
        #  data.getlist(name)
        #else
        #  data[name]
        #end
        data[name]
      end
    end

    class FileInput < Input
      self.input_type = 'file'
      self.needs_multipart_form = true

      def render(name, value, attrs=nil)
        super(name, nil, attrs)
      end

      def value_from_datahash(data, files, name)
        files.fetch(name, nil)
      end

      def has_changed?(initial, data)
        data.nil?
      end
    end

    class Textarea < Widget
      def initialize(attrs=nil)
        # The 'rows' and 'cols' attributes are required for HTML correctness.
        @attrs = {:cols => '40', :rows => '10'}
        @attrs.merge!(attrs) if attrs
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
        result = @check_test.call(value) rescue false
        final_attrs[:checked] = 'checked' if result
        final_attrs[:value] = value.to_s unless
          ['', true, false, nil].include?(value)
        mark_safe("<input#{flatatt(final_attrs)} />")
      end

      def value_from_datahash(data, files, name)
        data.include?(name) ? super(data, files, name) : false
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
        (@choices + choices).each do |option_value, option_label|
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

      def render_option(option_value, option_label, selected_choices)
        option_value = option_value.to_s
        selected_html = selected_choices.include?(option_value) ? ' selected="selected"' : ''
        "<option value=\"#{escape(option_value)}\"#{selected_html}>#{conditional_escape(option_label.to_s)}</option>"
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

      def value_from_datahash(data, files, name)
        value = data[name]
        case value
        when '2', true then true
        when '3', false then false
        else nil
        end
      end

      def has_changed?(initial, data)
        make_bool(initial) != make_bool(data)
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

      def value_from_datahash(data, files, name)
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
        return true if initial.length != data.length
        initial.zip(data).each do |value1, value2|
            return true if value1.to_s != value2.to_s
          end
        false
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
        lis = []
        each {|radio| lis << "<li>#{radio}</li>"}
        mark_safe("<ul>\n#{lis.join("\n")}\n</ul>")
      end
    end

    class RadioSelect < Select
      class << self
        attr_accessor :renderer
      end
      self.renderer = RadioFieldRenderer

      def initialize(*args)
        options = args.last.is_a?(Hash) ? args.last : {}
        @renderer = options.fetch(:renderer, self.class.renderer)
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

      def self.id_for_label(id_)
        id_.empty? ? id_ : id_ + '_0'
      end
    end

    class CheckboxSelectMultiple < SelectMultiple
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

      def self.id_for_label(id_)
        id_.empty? ? id_ : id_ + '_0'
      end
    end

    # TODO: MultiWidget < Widget
    # TODO: SplitDateTimeWidget < MultiWidget
    # TODO: SplitHiddenDateTimeWidget < SplitDateTimeWidget

  end
end
