require_relative '../test_helper'

module BooleanFieldTests
  class Test_on_clean < BureaucratTestCase
    def setup
      @true_values = [1, true, 'true', '1']
      @false_values = [nil, 0, false, 'false', '0']
      @field = Bureaucrat::Fields::BooleanField.new
    end

    def test_return_true_for_true_values
      @true_values.each do |true_value|
        assert_equal(true, @field.clean(true_value))
      end
    end

    def test_return_false_for_false_values
      @field.required = false
      @false_values.each do |false_value|
        assert_equal(false, @field.clean(false_value))
      end
    end

    def test_validate_on_true_values_when_required
      assert_nothing_raised do
        @true_values.each do |true_value|
          @field.clean(true_value)
        end
      end
    end

    def test_not_validate_on_false_values_when_required
      @false_values.each do |false_value|
        assert_raises(Bureaucrat::ValidationError) do
          @field.clean(false_value)
        end
      end
    end

    def test_validate_on_false_values_when_not_required
      @field.required = false
      assert_nothing_raised do
        @false_values.each do |false_value|
          @field.clean(false_value)
        end
      end
    end
  end
end
