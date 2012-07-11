require 'bureaucrat/fields/integer_field'
require_relative '../test_helper'

module IntegerFieldTests
  class Test_with_max_value < BureaucratTestCase
    def setup
      @field = Fields::IntegerField.new(max_value: 10)
    end

    def test_allow_values_less_or_equal_to_max_value
      assert_nothing_raised do
        @field.clean('10')
        @field.clean('4')
      end
    end

    def test_not_allow_values_greater_than_max_value
      assert_raises(ValidationError) do
        @field.clean('11')
      end
    end
  end

  class Test_with_min_value < BureaucratTestCase
    def setup
      @field = Fields::IntegerField.new(min_value: 10)
    end

    def test_allow_values_greater_or_equal_to_min_value
      assert_nothing_raised do
        @field.clean('10')
        @field.clean('20')
      end
    end

    def test_not_allow_values_less_than_min_value
      assert_raises(ValidationError) do
        @field.clean('9')
      end
    end
  end

  class Test_on_clean < BureaucratTestCase
    def setup
      @field = Fields::IntegerField.new
    end

    def test_return_an_integer_if_valid
      valid_value = '123'
      assert_equal(123, @field.clean(valid_value))
    end

    def test_return_nil_if_value_is_nil_and_required_is_false
      @field.required = false
      assert_nil(@field.clean(nil))
    end

    def test_return_nil_if_value_is_empty_and_required_is_false
      @field.required = false
      empty_value = ''
      assert_nil(@field.clean(empty_value))
    end

    def test_not_validate_invalid_formats
      invalid_formats = ['a', 'hello', '23eeee', '.', 'hi323',
                         'joe@example.com', '___3232___323',
                         '123.0', '123..4']

      invalid_formats.each do |invalid|
        assert_raises(ValidationError) do
          @field.clean(invalid)
        end
      end
    end

    def test_validate_valid_formats
      valid_formats = ['3', '100', '-100', '0', '-0']

      assert_nothing_raised do
        valid_formats.each do |valid|
          @field.clean(valid)
        end
      end
    end

    def test_return_an_instance_of_Integer_if_valid
      result = @field.clean('7')
      assert_kind_of(Integer, result)
    end
  end

  class Test_translate_errors < BureaucratTestCase
    def setup
      @field = Fields::IntegerField.new
    end

    def test_translates_min_value_error_default
      assert_equal(I18n.t('bureaucrat.default_errors.integer.min_value'), @field.error_messages[:min_value])
    end

    def test_translates_min_value_error
      @field.form_name = 'test_form'
      @field.name = 'test_field'
      assert_equal(I18n.t('bureaucrat.test_form.test_field.errors.min_value'), @field.error_messages[:min_value])
    end

    def test_translates_max_value_error_default
      assert_equal(I18n.t('bureaucrat.default_errors.integer.max_value'), @field.error_messages[:max_value])
    end

    def test_translates_max_value_error
      @field.form_name = 'test_form'
      @field.name = 'test_field'
      assert_equal(I18n.t('bureaucrat.test_form.test_field.errors.max_value'), @field.error_messages[:max_value])
    end

    def test_translates_invalid_error_default
      assert_equal(I18n.t('bureaucrat.default_errors.integer.invalid'), @field.error_messages[:invalid])
    end
  end
end
