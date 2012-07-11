require_relative '../test_helper'

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
      begin
        @field.clean([1])
      rescue ValidationError => e
        assert_equal(["Select a valid choice. 1 is not one of the available choices."], e.messages)
      end
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
end
