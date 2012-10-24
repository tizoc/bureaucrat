#--
# @copyright This file is copyright (C) 2000-2012 by Sittercity, Inc.
#            All rights reserved.
#            All Sittercity source code is CONFIDENTIAL and
#                not for distribution or unauthorized use.
#            For license information contact Sittercity, Inc.
#++

require 'bureaucrat'
require 'bureaucrat/fields/big_decimal_field'
require 'bureaucrat/validators/min_value'
require 'bureaucrat/validators/max_value'

module Bureaucrat
  module Fields
    class CurrencyField < ::Bureaucrat::Fields::BigDecimalField
      def initialize(options={})
        my_options = options.dup
        @min_dollars =  options[:min_dollars]
        @max_dollars =  options[:max_dollars]

        my_options[:max_decimal_places] = 2

        super(my_options)
        if @min_dollars
          self.validators << ::Bureaucrat::Validators::MinValueValidator.new(@min_dollars.to_i*100)
        end

        if @max_dollars
          self.validators << ::Bureaucrat::Validators::MaxValueValidator.new(@max_dollars.to_i*100)
        end

      end

      def clean(value)
        value = value.to_s.gsub(/^\$/, '') unless value.nil?
        value = super(value)
        value.to_i if value
      end

      def default_error_messages
        super.merge(invalid: error_message(:currency, :invalid),
                    max_value: error_message(:currency, :max_value, {max: @max_dollars}),
                    min_value: error_message(:currency, :min_value, {min: @min_dollars}),
                    max_decimal_places: error_message(:currency, :max_decimal_places, {max: 2}))
      end

      def bound_data(data, initial)
        initial
      end
    end
  end
end
