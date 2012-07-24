module Bureaucrat
  module Widgets
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

      def value_from_formdata(data, name)
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
  end
end
