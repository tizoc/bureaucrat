require 'bureaucrat/utils'

module Bureaucrat
module Validation

  class ValidationError < Exception
    attr_reader :error_code, :parameters

    def initialize(error_code, parameters=nil)
      @error_code = error_code
      @parameters = parameters || {}
    end
  end

  module Validates
    module_function
    def fail_with(error_code, parameters=nil)
      raise ValidationError.new(error_code, parameters)
    end
  end

  module Converters
    include Validates

    module_function

    def to_integer(string)
      Integer(string)
    rescue ArgumentError
      fail_with(:invalid)
    end

    def to_float(string)
      Utils.make_float(string)
    rescue ArgumentError
      fail_with(:invalid)
    end

    def to_big_decimal(string)
      Utils.make_float(string)
      BigDecimal.new(string)
    rescue ArgumentError
      fail_with(:invalid)
    end

    def to_bool(string)
      ['false', '0'].include?(string) ? false : Utils.make_bool(string)
    end
  end

  module Validators
    include Validates

    module_function

    def empty_value?(value)
      value.nil? || value == ''
    end

    def is_present(value)
      fail_with(:required) if empty_value?(value)
    end

    def not_empty(value)
      fail_with(:required) if value.empty?
    end

    def is_true(value)
      fail_with(:required) unless value
    end

    def is_array(value)
      fail_with(:invalid_list) unless value.kind_of?(Array)
    end

    def has_min_length(value, min_length)
      value_length = value.length
      fail_with(:min_length, :min => min_length,
                :length => value_length) if value_length < min_length
    end

    def has_max_length(value, max_length)
      value_length = value.length
      fail_with(:max_length, :max => max_length,
                :length => value_length) if value_length > max_length
    end

    def is_not_lesser_than(value, min_value)
      fail_with(:min_value, :min => min_value) if value < min_value
    end

    def is_not_greater_than(value, max_value)
      fail_with(:max_value, :max => max_value) if value > max_value
    end

    def has_max_digits(value, max_digits)
      sign, alldigits, _, whole_digits = value.split
      fail_with(:max_digits, :max => max_digits) if alldigits > max_digits
    end

    def has_max_decimal_places(values, decimal_places)
      sign, alldigits, _, whole_digits = value.split
      decimals = alldigits.length - whole_digits
      fail_with(:max_decimal_places, :max => decimal_places) if
        decimals > decimal_places
    end

    def has_max_whole_digits(value, max_digits)
      sign, alldigits, _, whole_digits = value.split
      fail_with(:max_digits, :max => max_digits) if alldigits > max_digits
    end

    def included_in(value, collection)
      fail_with(:not_included, :collection => collection) unless
        collection.include?(value)
    end

    def matches_regex(value, regex, error_code=:invalid)
      fail_with(error_code, :regex => regex) if regex !~ value
    end

    EMAIL_RE = /(^[-!#\$%&'*+\/=?^_`{}|~0-9A-Z]+(\.[-!#\$%&'*+\/=?^_`{}|~0-9A-Z]+)*|^"([\001-\010\013\014\016-\037!#-\[\]-\177]|\\[\001-011\013\014\016-\177])*")@(?:[A-Z0-9]+(?:-*[A-Z0-9]+)*\.)+[A-Z]{2,6}$/i

    def is_email(value)
      matches_regex(value, EMAIL_RE)
    end
  end

end
end
