require 'bureaucrat/widgets/radio_field_renderer'
require 'bureaucrat/widgets/select'

module Bureaucrat
  module Widgets
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
        choices = @choices.to_a + choices.to_a
        @renderer.new(name, str_value, final_attrs, choices)
      end

      def render(name, value, attrs=nil, choices=[])
        get_renderer(name, value, attrs, choices).render
      end
    end
  end
end
