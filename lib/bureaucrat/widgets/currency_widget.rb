#--
# @copyright This file is copyright (C) 2000-2012 by Sittercity, Inc.
#            All rights reserved.
#            All Sittercity source code is CONFIDENTIAL and
#                not for distribution or unauthorized use.
#            For license information contact Sittercity, Inc.
#++

require 'bureaucrat/widgets/text_input'

module Bureaucrat
  module Widgets
    class CurrencyWidget < Bureaucrat::Widgets::TextInput
      def render(name, value, attrs)
        super(name, format_dollars(value), attrs)
      end

      def value_from_formdata(data, name)
        return nil if data.nil?
        value = data[name]
        return value if value.is_a? Integer
        string_value = value.to_s if value
        return string_value if string_value.nil? || string_value.empty?
        match = string_value.match(/\A\$?([+-]?\d*\.?\d{,2})\Z/) if string_value
        return (match[1].to_f * 100).to_i if match
        return string_value
      end

      def form_value(data, name)
        format_dollars(value_from_formdata(data, name))
      end

      private

      def format_dollars(value)
        return '' if /[^0-9.]/ =~ value.to_s
        return value if /[.]/ =~ value.to_s
        '%.2f' % (value.to_f / 100) unless value.nil? || value.to_s.empty?
      end
    end
  end
end
