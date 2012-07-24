require_relative '../test_helper'

module RegexFieldTests
  class Test_on_clean < BureaucratTestCase
    def setup
      @field = Fields::RegexField.new(/ba(na){2,}/)
    end

    def test_validate_matching_values
      valid_values = ['banana', 'bananananana']
      valid_values.each do |valid|
        assert_nothing_raised do
          @field.clean(valid)
        end
      end
    end

    def test_not_validate_non_matching_values
      invalid_values = ['bana', 'spoon']
      assert_raises(ValidationError) do
        invalid_values.each do |invalid|
          @field.clean(invalid)
        end
      end
    end

    def test_return_a_blank_string_if_value_is_empty_and_required_is_false
      @field.required = false
      empty_value = ''
      assert_equal('', @field.clean(empty_value))
    end
  end
end
