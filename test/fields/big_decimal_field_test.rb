require_relative '../test_helper'

module BigDecimalFieldTests
  class Test_with_max_digits_and_decimal_places < BureaucratTestCase
    def setup
      @field = Fields::BigDecimalField.new(max_digits: 8, max_decimal_places: 4)
    end

    def test_not_allow_values_greater_than_max_digits
      assert_raises(ValidationError) do
        @field.clean('123456789')
      end
    end

    def test_not_allow_values_greater_than_max_decimal_places
      assert_raises(ValidationError) do
        @field.clean('12.34567')
      end
    end
  end

  class Test_with_max_value < BureaucratTestCase
    def setup
      @field = Fields::BigDecimalField.new(max_value: 10.5)
    end

    def test_allow_values_less_or_equal_to_max_value
      assert_nothing_raised do
        @field.clean('10.5')
        @field.clean('5')
      end
    end

    def test_not_allow_values_greater_than_max_value
      assert_raises(ValidationError) do
        @field.clean('10.55')
      end
    end
  end

  class Test_with_min_value < BureaucratTestCase
    def setup
      @field = Fields::BigDecimalField.new(min_value: 10.5)
    end

    def test_allow_values_greater_or_equal_to_min_value
      assert_nothing_raised do
        @field.clean('10.5')
        @field.clean('20.5')
      end
    end

    def test_not_allow_values_less_than_min_value
      assert_raises(ValidationError) do
        @field.clean('10.49')
      end
    end
  end

  class Test_on_clean < BureaucratTestCase
    def setup
      @field = Fields::BigDecimalField.new
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
                         '123..', '123..4']

      invalid_formats.each do |invalid|
        assert_raises(ValidationError) do
          @field.clean(invalid)
        end
      end
    end

    def test_validate_valid_formats
      valid_formats = ['3.14', "100", "1233.", ".3333", "0.434", "0.0"]

      assert_nothing_raised do
        valid_formats.each do |valid|
          @field.clean(valid)
        end
      end
    end

    def test_return_an_instance_of_BigDecimal_if_valid
      result = @field.clean('3.14')
      assert_instance_of(BigDecimal, result)
    end
  end

  class Test_translation_errors < BureaucratTestCase
    def setup
      @field = Fields::BigDecimalField.new
    end

    def test_translates_invalid_default
      assert_equal(I18n.t('bureaucrat.default_errors.big_decimal.invalid'), @field.error_messages[:invalid])
    end

    def test_translates_max_value_default
      assert_equal(I18n.t('bureaucrat.default_errors.big_decimal.max_value'), @field.error_messages[:max_value])
    end

    def test_translates_min_value_default
      assert_equal(I18n.t('bureaucrat.default_errors.big_decimal.min_value'), @field.error_messages[:min_value])
    end

    def test_translates_max_digits_default
      assert_equal(I18n.t('bureaucrat.default_errors.big_decimal.max_digits'), @field.error_messages[:max_digits])
    end

    def test_translates_max_digits_error
      @field.form_name = 'test_form'
      @field.name = 'test_field'
      assert_equal(I18n.t('bureaucrat.test_form.test_field.errors.max_digits'), @field.error_messages[:max_digits])
    end

    def test_translates_max_decimal_places_default
      assert_equal(I18n.t('bureaucrat.default_errors.big_decimal.max_decimal_places'), @field.error_messages[:max_decimal_places])
    end

    def test_translates_max_decimal_places_error
      @field.form_name = 'test_form'
      @field.name = 'test_field'
      assert_equal(I18n.t('bureaucrat.test_form.test_field.errors.max_decimal_places'), @field.error_messages[:max_decimal_places])
    end

    def test_translates_max_whole_digits_default
      assert_equal(I18n.t('bureaucrat.default_errors.big_decimal.max_whole_digits'), @field.error_messages[:max_whole_digits])
    end

    def test_translates_max_whole_digits_error
      @field.form_name = 'test_form'
      @field.name = 'test_field'
      assert_equal(I18n.t('bureaucrat.test_form.test_field.errors.max_whole_digits'), @field.error_messages[:max_whole_digits])
    end
  end
end
