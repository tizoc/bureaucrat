require_relative '../test_helper'
require 'bureaucrat/fields/date_field'

module DateFieldTests
  class Test_on_clean < BureaucratTestCase
    def setup
      @field = Bureaucrat::Fields::DateField.new
    end

    def test_accepts_date_as_valid
      assert_nothing_raised do
        @field.clean(Date.parse('1982/10/25'))
      end
    end

    def test_does_not_accept_not_date_values
      assert_raises(Bureaucrat::ValidationError) do
        @field.clean('str')
      end
    end

    def test_return_nil_if_value_is_empty_and_required_is_false
      @field.required = false
      empty_value = ''
      assert_equal(nil, @field.clean(empty_value))
    end

    def test_return_value_if_value_is_already_date
      value = Date.parse('1982/10/25')
      assert_equal(value, @field.clean(value))
    end

    def test_date_before_min_is_invalid
      field = Bureaucrat::Fields::DateField.new({min: Date.today})

      assert_raises(Bureaucrat::ValidationError) do
        field.clean(Date.parse("1977/1/1"))
      end
    end

    def test_date_after_max_is_invalid
      field = Bureaucrat::Fields::DateField.new({max: Date.parse("1977/1/1")})

      assert_raises(Bureaucrat::ValidationError) do
        field.clean(Date.today)
      end
    end
  end

  class Test_translation_errors < BureaucratTestCase
    def setup
      @field = Bureaucrat::Fields::DateField.new
    end

    def test_translates_invalid_default
      assert_equal(I18n.t('bureaucrat.default_errors.fields.date.invalid'), @field.error_messages[:invalid])
    end
  end
end
