require 'bureaucrat/widgets/select'

module Bureaucrat
  module Widgets
    class SelectMultiple < Select
      def render(name, value, attrs=nil, choices=[])
        value = [] if value.nil?
        final_attrs = build_attrs(attrs, name: "#{name}[]")
        output = ["<select multiple=\"multiple\"#{flatatt(final_attrs)}>"]
        options = render_options(choices, value)
        output << options if options && !options.empty?
        output << '</select>'
        mark_safe(output.join("\n"))
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
  end
end

