require_relative '../test_helper'

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
