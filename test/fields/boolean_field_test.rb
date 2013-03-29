require_relative '../test_helper'

module BooleanFieldTests
  class Test_on_clean < BureaucratTestCase
    def setup
      @true_values = [1, true, 'true', '1']
      @false_values = [0, false, 'false', '0']
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

    def test_valid_on_false_values_when_required
      @false_values.each do |false_value|
        assert_nothing_raised do
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

    def test_nil_does_not_get_converted_to_false_if_required
      assert_nil(@field.to_object(nil))
    end

    def test_nil_value_is_invalid_if_required
      assert_raises(Bureaucrat::ValidationError) do
        @field.clean(nil)
      end
    end
  end
end
