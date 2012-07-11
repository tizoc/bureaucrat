require_relative '../test_helper'

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
