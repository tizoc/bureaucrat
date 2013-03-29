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

    def test_time_objects_are_also_acceptable
      field = Bureaucrat::Fields::DateField.new({max: Date.today + 1})

      assert_nothing_raised do
        field.clean(Time.now)
      end
    end
  end

  class Test_translation_errors < BureaucratTestCase
    def test_translates_invalid_default
      field = Bureaucrat::Fields::DateField.new
      assert_equal(I18n.t('bureaucrat.default_errors.fields.date.invalid'), field.error_messages[:invalid])
    end
  end

  class Test_date_input_limit_translation_errors < BureaucratTestCase
    def setup
      @format = '%m-%d-%Y'
      @today = Date.today
      @tomorrow = Date.today + 1
      @field = Bureaucrat::Fields::DateField.new(
        min: @today, max: @tomorrow,
        widget: Bureaucrat::Widgets::DateInput.new(nil, ['%m-%d-%Y'])
      )
    end

    def test_errors_format_date_to_given_date_format_for_min_date
      date = Date.today - 1
      @field.clean(date)

    rescue Bureaucrat::ValidationError => e
      expected_errors = I18n.t(
        "bureaucrat.default_errors.validators.min_value_validator",
        limit_value: @today.strftime(@format)
      )
      assert_equal(expected_errors, e.messages.first)
    end

    def test_errors_format_date_to_given_date_format_for_max_date
      date = Date.today + 3
      @field.clean(date)

    rescue Bureaucrat::ValidationError => e
      expected_errors = I18n.t(
        "bureaucrat.default_errors.validators.max_value_validator",
        limit_value: @tomorrow.strftime(@format)
      )
      assert_equal(expected_errors, e.messages.first)
    end

    class Test_multidate_limit_translation_errors < BureaucratTestCase
      def setup
        @format = '%m-%d-%Y'
        @today = Date.today
        @tomorrow = Date.today + 1
        @field = Bureaucrat::Fields::DateField.new(
          min: @today, max: @tomorrow,
          widget: Bureaucrat::Widgets::MultiDate.new({}, {}, '%m-%d-%Y')
        )
      end

      def test_errors_format_date_to_given_date_format_for_min_date
        date = Date.today - 1
        @field.clean(date)

      rescue Bureaucrat::ValidationError => e
        expected_errors = I18n.t(
          "bureaucrat.default_errors.validators.min_value_validator",
          limit_value: @today.strftime(@format)
        )
        assert_equal(expected_errors, e.messages.first)
      end

      def test_errors_format_date_to_given_date_format_for_max_date
        date = Date.today + 3
        @field.clean(date)

      rescue Bureaucrat::ValidationError => e
        expected_errors = I18n.t(
          "bureaucrat.default_errors.validators.max_value_validator",
          limit_value: @tomorrow.strftime(@format)
        )
        assert_equal(expected_errors, e.messages.first)
      end
    end
  end
end
