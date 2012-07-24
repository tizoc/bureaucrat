require_relative '../test_helper'

module TypedChoiceFieldTests
  class Test_on_clean < BureaucratTestCase
    def setup
      @choices = [[1, 'One'], [2, 'Two'], ['3', 'Three']]
      to_int = lambda{|val| Integer(val)}
      @field = Fields::TypedChoiceField.new(@choices,
                                            coerce: to_int)
    end

    def test_validate_all_values_in_choices_list
      assert_nothing_raised do
        @choices.collect(&:first).each do |valid|
          @field.clean(valid)
        end
      end
    end

    def test_not_validate_a_value_not_in_choices_list
      assert_raises(ValidationError) do
        @field.clean('four')
      end
    end

    def test_return_the_original_value_if_valid
      value = 1
      result = @field.clean(value)
      assert_equal(value, result)
    end

    def test_return_a_coerced_version_of_the_original_value_if_valid_but_of_different_type
      value = 2
      result = @field.clean(value.to_s)
      assert_equal(value, result)
    end

    def test_return_an_empty_string_if_value_is_empty_and_not_required
      @field.required = false
      result = @field.clean('')
      assert_equal('', result)
    end
  end
end
