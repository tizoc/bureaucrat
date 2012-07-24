require_relative '../test_helper'

module CharFieldTests
  class Test_with_empty_options < BureaucratTestCase
    def setup
      @field = Fields::CharField.new
    end

    def test_not_validate_max_length
      assert_nothing_raised do
        @field.clean("string" * 1000)
      end
    end

    def test_not_validate_min_length
      assert_nothing_raised do
        @field.clean("1")
      end
    end
  end

  class Test_with_max_length < BureaucratTestCase
    def setup
      @field = Fields::CharField.new(max_length: 10)
    end

    def test_allow_values_with_length_less_than_or_equal_to_max_length
      assert_nothing_raised do
        @field.clean('a' * 10)
        @field.clean('a' * 5)
      end
    end

    def test_not_allow_values_with_length_greater_than_max_length
      assert_raises(ValidationError) do
        @field.clean('a' * 11)
      end
    end
  end

  class Test_with_min_length < BureaucratTestCase
    def setup
      @field = Fields::CharField.new(min_length: 10)
    end

    def test_allow_values_with_length_greater_or_equal_to_min_length
      assert_nothing_raised do
        @field.clean('a' * 10)
        @field.clean('a' * 20)
      end
    end

    def test_not_allow_values_with_length_less_than_min_length
      assert_raises(ValidationError) do
        @field.clean('a' * 9)
      end
    end
  end

  class Test_on_clean < BureaucratTestCase
    def setup
      @field = Fields::CharField.new
    end

    def test_return_the_original_value_if_valid
      valid_value = 'test'
      assert_equal(valid_value, @field.clean(valid_value))
    end

    def test_return_a_blank_string_if_value_is_nil_and_required_is_false
      @field.required = false
      nil_value = nil
      assert_equal('', @field.clean(nil_value))
    end

    def test_return_a_blank_string_if_value_is_empty_and_required_is_false
      @field.required = false
      empty_value = ''
      assert_equal('', @field.clean(empty_value))
    end
  end

  class Test_translation_errors < BureaucratTestCase
    def setup
      @field = Fields::CharField.new(max_length: 10, min_length: 2)
    end

    def test_translates_max_length_default
      assert_equal('Ensure this value is less than or equal to 10.', @field.error_messages[:max_length])
    end

    def test_translates_min_length_default
      assert_equal('Ensure this value is greater than or equal to 2.', @field.error_messages[:min_length])
    end
  end
end
