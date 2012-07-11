require_relative 'test_helper'

module FieldTests
  class Test_with_empty_options < BureaucratTestCase
    def setup
      @field = Fields::Field.new
    end

    def test_be_required
      blank_value = ''
      assert_raises(ValidationError) do
        @field.clean(blank_value)
      end
    end
  end

  class Test_with_required_as_false < BureaucratTestCase
    def setup
      @field = Fields::Field.new(required: false)
    end

    def test_not_be_required
      blank_value = ''
      assert_nothing_raised do
        @field.clean(blank_value)
      end
    end
  end

  class Test_on_clean < BureaucratTestCase
    def setup
      @field = Fields::Field.new
    end

    def test_return_the_original_value_if_valid
      value = 'test'
      assert_equal(value, @field.clean(value))
    end
  end

  class Test_when_copied < BureaucratTestCase
    def setup
      @field = Fields::Field.new(initial: 'initial',
                                 label: 'label')
      @field_copy = @field.dup
    end

    def test_have_its_own_copy_of_initial_value
      assert_not_equal(@field.initial.object_id, @field_copy.initial.object_id)
    end

    def test_have_its_own_copy_of_the_label
      assert_not_equal(@field.label.object_id, @field_copy.label.object_id)
    end

    def test_have_its_own_copy_of_the_widget
      assert_not_equal(@field.widget.object_id, @field_copy.widget.object_id)
    end

    def test_have_its_own_copy_of_validators
      assert_not_equal(@field.validators.object_id, @field_copy.validators.object_id)
    end

    def test_have_its_own_copy_of_the_error_messaes
      assert_not_equal(@field.error_messages.object_id, @field_copy.error_messages.object_id)
    end
  end

  class Test_translated_errors < BureaucratTestCase
    def setup
      @field = Fields::Field.new(initial: 'initial',
                                 label: 'label')
    end

    def test_translates_required_default
      assert_equal(I18n.t('bureaucrat.default_errors.field.required'), @field.error_messages[:required])
    end

    def test_translates_required_fields
      @field.form_name = 'test_form'
      @field.name = 'test_field'
      assert_equal(I18n.t('bureaucrat.test_form.test_field.errors.required'), @field.error_messages[:required])
    end

    def test_translates_invalid_fields
      @field.form_name = 'test_form'
      @field.name = 'test_field'
      assert_equal(I18n.t('bureaucrat.test_form.test_field.errors.invalid'), @field.error_messages[:invalid])
    end
  end

  class Test_label < BureaucratTestCase
    def setup
      @field = Fields::Field.new
    end

    def test_uses_translation_if_no_default_is_given_and_translation_present
      @field.form_name = 'test_form'
      @field.name = 'test_field'
      assert_equal(I18n.t('bureaucrat.test_form.test_field.label'), @field.label)
    end

    def test_uses_default_if_given
      new_field = Fields::Field.new(label: "something")
      assert_equal("something", new_field.label)
    end

    def test_gives_a_pretty_name_if_translation_not_present
      @field.name = 'test_field'
      assert_equal('Test field', @field.label)
    end
  end
end

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
end

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

module FloatFieldTests
  class Test_with_max_value < BureaucratTestCase
    def setup
      @field = Fields::FloatField.new(max_value: 10.5)
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
      @field = Fields::FloatField.new(min_value: 10.5)
    end

    def test_allow_values_greater_or_equal_than_min_value
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
      @field = Fields::FloatField.new
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

    def test_return_an_instance_of_Float_if_valid
      result = @field.clean('3.14')
      assert_instance_of(Float, result)
    end
  end

  class Test_translation_errors < BureaucratTestCase
    def setup
      @field = Fields::FloatField.new
    end

    def test_translates_invalid_default
      assert_equal(I18n.t('bureaucrat.default_errors.float.invalid'), @field.error_messages[:invalid])
    end
  end
end

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
      assert_equal(I18n.t('bureaucrat.default_errors.date.invalid'), @field.error_messages[:invalid])
    end
  end
end

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

module EmailFieldTests
  class Test_on_clean < BureaucratTestCase
    def setup
      @field = Fields::EmailField.new
    end

    def test_validate_email_matching_values
      valid_values = ['email@domain.com', 'email+extra@domain.com',
                      'email@domain.fm', 'email@domain.co.uk']
      valid_values.each do |valid|
        assert_nothing_raised do
          @field.clean(valid)
        end
      end
    end

    def test_not_validate_non_email_matching_values
      invalid_values = ['banana', 'spoon', 'invalid@dom#ain.com',
                        'invalid@@domain.com', 'invalid@domain',
                        'invalid@.com']
      invalid_values.each do |invalid|
        assert_raises(ValidationError) do
          @field.clean(invalid)
        end
      end
    end
  end

  class Test_translation_errors < BureaucratTestCase
    def setup
      @field = Fields::EmailField.new
    end

    def test_translates_invalid_default
      assert_equal(I18n.t('bureaucrat.default_errors.email.invalid'), @field.error_messages[:invalid])
    end
  end
end

module FileFieldTests
  class Test_translation_errors < BureaucratTestCase
    def setup
      @field = Fields::FileField.new({})
    end

    def test_translates_invalid_default
      assert_equal(I18n.t('bureaucrat.default_errors.file.invalid'), @field.error_messages[:invalid])
    end

    def test_translates_invalid
      @field.form_name = 'test_form'
      @field.name = 'test_field'
      assert_equal(I18n.t('bureaucrat.test_form.test_field.errors.invalid'), @field.error_messages[:invalid])
    end

    def test_translates_missing
      @field.form_name = 'test_form'
      @field.name = 'test_field'
      assert_equal(I18n.t('bureaucrat.test_form.test_field.errors.missing'), @field.error_messages[:missing])
    end

    def test_translates_missing_default
      assert_equal(I18n.t('bureaucrat.default_errors.file.missing'), @field.error_messages[:missing])
    end

    def test_translates_empty_default
      assert_equal(I18n.t('bureaucrat.default_errors.file.empty'), @field.error_messages[:empty])
    end

    def test_translates_empty
      @field.form_name = 'test_form'
      @field.name = 'test_field'
      assert_equal(I18n.t('bureaucrat.test_form.test_field.errors.empty'), @field.error_messages[:empty])
    end

    def test_translates_max_length_default
      assert_equal(I18n.t('bureaucrat.default_errors.file.max_length'), @field.error_messages[:max_length])
    end

    def test_translates_max_length
      @field.form_name = 'test_form'
      @field.name = 'test_field'
      assert_equal(I18n.t('bureaucrat.test_form.test_field.errors.max_length'), @field.error_messages[:max_length])
    end

    def test_translates_contradiction_default
      assert_equal(I18n.t('bureaucrat.default_errors.file.contradiction'), @field.error_messages[:contradiction])
    end

    def test_translates_contradiction
      @field.form_name = 'test_form'
      @field.name = 'test_field'
      assert_equal(I18n.t('bureaucrat.test_form.test_field.errors.contradiction'), @field.error_messages[:contradiction])
    end
  end
end

module BooleanFieldTests
  class Test_on_clean < BureaucratTestCase
    def setup
      @true_values = [1, true, 'true', '1']
      @false_values = [nil, 0, false, 'false', '0']
      @field = Fields::BooleanField.new
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
        assert_raises(ValidationError) do
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

module NullBooleanFieldTests
  class Test_on_clean < BureaucratTestCase
    def setup
      @true_values = [true, 'true', '1']
      @false_values = [false, 'false', '0']
      @null_values = [nil, '', 'banana']
      @field = Fields::NullBooleanField.new
    end

    def test_return_true_for_true_values
      @true_values.each do |true_value|
        assert_equal(true, @field.clean(true_value))
      end
    end

    def test_return_false_for_false_values
      @false_values.each do |false_value|
        assert_equal(false, @field.clean(false_value))
      end
    end

    def test_return_nil_for_null_values
      @null_values.each do |null_value|
        assert_equal(nil, @field.clean(null_value))
      end
    end

    def test_validate_on_all_values
      all_values = @true_values + @false_values + @null_values
      assert_nothing_raised do
        all_values.each do |value|
          @field.clean(value)
        end
      end
    end
  end
end

module ChoiceFieldTests
  class Test_when_copied < BureaucratTestCase
    def setup
      @choices = [['tea', 'Tea'], ['milk', 'Milk']]
      @field = Fields::ChoiceField.new(@choices)
      @field_copy = @field.dup
    end

    def test_have_its_own_copy_of_choices
      assert_not_equal(@field.choices.object_id, @field_copy.choices.object_id)
    end
  end

  class Test_on_clean < BureaucratTestCase
    def setup
      @choices = [['tea', 'Tea'], ['milk', 'Milk']]
      @choices_hash = [[{ value: "able" }, "able"], [{ value: "baker" }, "Baker"]]
      @field = Fields::ChoiceField.new(@choices)
      @field_hash = Fields::ChoiceField.new(@choices_hash)
    end

    def test_validate_all_values_in_choices_list
      assert_nothing_raised do
        @choices.collect(&:first).each do |valid|
          @field.clean(valid)
        end
      end
    end

    def test_validate_all_values_in_a_hash_choices_list
      assert_nothing_raised do
        @choices_hash.collect(&:first).each do |valid|
          @field_hash.clean(valid[:value])
        end
      end
    end

    def test_not_validate_a_value_not_in_choices_list
      assert_raises(ValidationError) do
        @field.clean('not_in_choices')
      end
    end

    def test_not_validate_a_value_not_in_a_hash_choices_list
      assert_raises(ValidationError) do
        @field_hash.clean('not_in_choices')
      end
    end

    def test_return_the_original_value_if_valid
      value = 'tea'
      result = @field.clean(value)
      assert_equal(value, result)
    end

    def test_return_the_original_value_if_valid_from_a_hash_choices_list
      value = 'baker'
      result = @field_hash.clean(value)
      assert_equal(value, result)
    end

    def test_return_an_empty_string_if_value_is_empty_and_not_required
      @field.required = false
      result = @field.clean('')
      assert_equal('', result)
    end

    def test_return_an_empty_string_if_value_is_empty_and_not_required_from_a_hash_choices_list
      @field_hash.required = false
      result = @field_hash.clean('')
      assert_equal('', result)
    end
  end

  class Test_translation_errors < BureaucratTestCase
    def setup
      @field = Fields::ChoiceField.new({})
    end

    def test_translates_invalid_choice_default
      assert_equal(I18n.t('bureaucrat.default_errors.choice.invalid_choice'), @field.error_messages[:invalid_choice])
    end

    def test_translates_invalid_choice
      @field.form_name = 'test_form'
      @field.name = 'test_field'
      assert_equal(I18n.t('bureaucrat.test_form.test_field.errors.invalid_choice'), @field.error_messages[:invalid_choice])
    end
  end
end

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

module MultipleChoiceFieldTests
  class Test_on_clean < BureaucratTestCase
    def setup
      @choices = [['tea', 'Tea'], ['milk', 'Milk'], ['coffee', 'Coffee']]
      @field = Fields::MultipleChoiceField.new(@choices)
    end

    def test_validate_all_single_values_in_choices_list
      assert_nothing_raised do
        @choices.collect(&:first).each do |valid|
          @field.clean([valid])
        end
      end
    end

    def test_validate_multiple_values
      values = ['tea', 'coffee']
      assert_nothing_raised do
        @field.clean(values)
      end
    end

    def test_not_validate_a_value_not_in_choices_list
      assert_raises(ValidationError) do
        @field.clean(['tea', 'not_in_choices'])
      end
    end

    def test_return_the_original_value_if_valid
      value = 'tea'
      result = @field.clean([value])
      assert_equal([value], result)
    end

    def test_return_an_empty_list_if_value_is_empty_and_not_required
      @field.required = false
      result = @field.clean([])
      assert_equal([], result)
    end
  end

  class Test_translation_errors < BureaucratTestCase
    def setup
      @field = Fields::MultipleChoiceField.new({})
    end

    def test_translates_invalid_choice_default
      assert_equal(I18n.t('bureaucrat.default_errors.multiple_choice.invalid_choice'), @field.error_messages[:invalid_choice])
    end

    def test_translates_invalid_list_default
      assert_equal(I18n.t('bureaucrat.default_errors.multiple_choice.invalid_list'), @field.error_messages[:invalid_list])
    end

    def test_translates_invalid_list
      @field.form_name = 'test_form'
      @field.name = 'test_field'
      assert_equal(I18n.t('bureaucrat.test_form.test_field.errors.invalid_list'), @field.error_messages[:invalid_list])
    end
  end

  module IPAddressFieldTests
    class Test_translation_errors < BureaucratTestCase
      def setup
        @field = Fields::IPAddressField.new({})
      end

      def test_translates_invalid_default
        assert_equal(I18n.t('bureaucrat.default_errors.ip_address.invalid'), @field.error_messages[:invalid])
      end

      def test_translates_invalid_default
        assert_equal(I18n.t('bureaucrat.default_errors.ip_address.invalid'), @field.error_messages[:invalid])
      end
    end
  end
end
