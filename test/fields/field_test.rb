require_relative '../test_helper'

module FieldTests
  class Test_with_empty_options < BureaucratTestCase
    def setup
      @field = Bureaucrat::Fields::Field.new
    end

    def test_be_required
      blank_value = ''
      assert_raises(Bureaucrat::ValidationError) do
        @field.clean(blank_value)
      end
    end
  end

  class Test_with_required_as_false < BureaucratTestCase
    def setup
      @field = Bureaucrat::Fields::Field.new(required: false)
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
      @field = Bureaucrat::Fields::Field.new
    end

    def test_return_the_original_value_if_valid
      value = 'test'
      assert_equal(value, @field.clean(value))
    end
  end

  class Test_when_copied < BureaucratTestCase
    def setup
      @field = Bureaucrat::Fields::Field.new(initial: 'initial',
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
      @field = Bureaucrat::Fields::Field.new(initial: 'initial',
                                 label: 'label')
    end

    def test_translates_required_default
      assert_equal(I18n.t('bureaucrat.default_errors.fields.field.required'), @field.error_messages[:required])
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
      @field = Bureaucrat::Fields::Field.new
    end

    def test_uses_translation_if_no_default_is_given_and_translation_present
      @field.form_name = 'test_form'
      @field.name = 'test_field'
      assert_equal(I18n.t('bureaucrat.test_form.test_field.label'), @field.label)
    end

    def test_uses_default_if_given
      new_field = Bureaucrat::Fields::Field.new(label: "something")
      assert_equal("something", new_field.label)
    end

    def test_gives_a_pretty_name_if_translation_not_present
      @field.name = 'test_field'
      assert_equal('Test field', @field.label)
    end
  end
end
