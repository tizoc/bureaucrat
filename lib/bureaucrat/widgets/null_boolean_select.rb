require 'bureaucrat/widgets/select'

module Bureaucrat
  module Widgets
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

      def value_from_formdata(data, name)
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
  end
end
