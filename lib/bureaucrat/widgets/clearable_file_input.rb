require 'bureaucrat/widgets/file_input'

module Bureaucrat
  module Widgets
    class ClearableFileInput < FileInput
      FILE_INPUT_CONTRADICTION = Object.new

      def initial_text
        'Currently'
      end

      def input_text
        'Change'
      end

      def clear_checkbox_label
        'Clear'
      end

      def template_with_initial
        '%(initial_text)s: %(initial)s %(clear_template)s<br />%(input_text)s: %(input)s'
      end

      def template_with_clear
        '%(clear)s <label for="%(clear_checkbox_id)s">%(clear_checkbox_label)s</label>'
      end

      def clear_checkbox_name(name)
        "#{name}-clear"
      end

      def clear_checkbox_id(checkbox_name)
        "#{checkbox_name}_id"
      end

      def render(name, value, attrs = nil)
        substitutions = {
          initial_text: initial_text,
          input_text: input_text,
          clear_template: '',
          clear_checkbox_label: clear_checkbox_label
        }
        template = '%(input)s'
        substitutions[:input] = super(name, value, attrs)

        if value && value.respond_to?(:url) && value.url
          template = template_with_initial
          substitutions[:initial] = '<a href="%s">%s</a>' % [escape(value.url),
                                                             escape(value.to_s)]
          unless is_required
            checkbox_name = clear_checkbox_name(name)
            checkbox_id = clear_checkbox_id(checkbox_name)
            substitutions[:clear_checkbox_name] = conditional_escape(checkbox_name)
            substitutions[:clear_checkbox_id] = conditional_escape(checkbox_id)
            substitutions[:clear] = CheckboxInput.new.
              render(checkbox_name, false, {id: checkbox_id})
            substitutions[:clear_template] =
              Utils.format_string(template_with_clear, substitutions)
          end
        end

        mark_safe(Utils.format_string(template, substitutions))
      end

      def value_from_formdata(data, name)
        upload = super(data, name)
        checked = CheckboxInput.new.
          value_from_formdata(data, clear_checkbox_name(name))

        if !is_required && checked
          if upload
            # If the user contradicts themselves (uploads a new file AND
            # checks the "clear" checkbox), we return a unique marker
            # object that FileField will turn into a ValidationError.
            FILE_INPUT_CONTRADICTION
          else
            # False signals to clear any existing value, as opposed to just None
            false
          end
        else
          upload
        end
      end
    end
  end
end
