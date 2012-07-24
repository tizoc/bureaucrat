require 'bureaucrat/widgets/widget'

module Bureaucrat
  module Widgets
    class CheckboxInput < Widget
      def initialize(attrs=nil, check_test=nil)
        super(attrs)
        @check_test = check_test || lambda {|v| make_bool(v)}
      end

      def render(name, value, attrs=nil)
        final_attrs = build_attrs(attrs, type: 'checkbox', name: name.to_s)

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

      def value_from_formdata(data, name)
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
  end
end
