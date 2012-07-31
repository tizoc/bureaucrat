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
        value = "%.2f" % (value.to_f/100) unless value.nil? || value.to_s.empty?
        super(name, value, attrs)
      end

      def value_from_formdata(data, name)
        return nil if data.nil?
        string_value = data[name]
        return string_value if string_value.nil? || string_value.empty?
        match = string_value.match(/\A\$?(\d*\.?\d{,2})\Z/) if string_value
        return (match[1].to_f * 100).to_i if match
        return string_value
      end
    end
  end
end
