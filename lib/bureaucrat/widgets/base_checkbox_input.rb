require 'bureaucrat/widgets/widget'

module Bureaucrat
  module Widgets
    class BaseCheckboxInput < Widget
      def initialize(attrs=nil, check_test=nil)
        super(attrs)
        @check_test = check_test || lambda {|v| make_bool(v)}
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
    end
  end
end

