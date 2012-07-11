require_relative '../test_helper'

module DateFieldTests
  class Test_on_clean < BureaucratTestCase
    def setup
      @field = Fields::DateField.new(['%Y/%m/%d', '%A %B %e %Y'])
    end

    def test_validate_valid_date_formats
      valid_values = ['1982/10/25', 'Sunday January 2 1983']
      valid_values.each do |valid|
        assert_nothing_raised do
          @field.clean(valid)
        end
      end
    end

    def test_not_validate_non_matching_values
      invalid_values = ['1982', 'Sunday']
      assert_raises(ValidationError) do
        invalid_values.each do |invalid|
          @field.clean(invalid)
        end
      end
    end

    def test_return_nil_if_value_is_empty_and_required_is_false
      @field.required = false
      empty_value = ''
      assert_equal(nil, @field.clean(empty_value))
    end

    def test_return_date_if_value_is_a_datetime
      value = DateTime.parse('1982/10/25 12:30 p.m.')
      assert_block do
        @field.clean(value).is_a? Date
      end
    end

    def test_return_value_if_value_is_already_date
      value = Date.parse('1982/10/25')
      assert_equal(value, @field.clean(value))
    end
  end

  class Test_translation_errors < BureaucratTestCase
    def setup
      @field = Fields::DateField.new([])
    end

    def test_translates_invalid_default
      assert_equal(I18n.t('bureaucrat.default_errors.fields.date.invalid'), @field.error_messages[:invalid])
    end
  end
end
