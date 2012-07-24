require_relative '../test_helper'
require 'bureaucrat/fields/null_boolean_field'

module NullBooleanFieldTests
  class Test_on_clean < BureaucratTestCase
    def setup
      @true_values = [true, 'true', '1']
      @false_values = [false, 'false', '0']
      @null_values = [nil, '', 'banana']
      @field = Bureaucrat::Fields::NullBooleanField.new
    end

    def test_return_true_for_true_values
      @true_values.each do |true_value|
        assert_equal(true, @field.clean(true_value))
      end
    end

    def test_return_false_for_false_values
      @false_values.each do |false_value|
        assert_equal(false, @field.clean(false_value))
      end
    end

    def test_return_nil_for_null_values
      @null_values.each do |null_value|
        assert_equal(nil, @field.clean(null_value))
      end
    end

    def test_validate_on_all_values
      all_values = @true_values + @false_values + @null_values
      assert_nothing_raised do
        all_values.each do |value|
          @field.clean(value)
        end
      end
    end
  end
end
