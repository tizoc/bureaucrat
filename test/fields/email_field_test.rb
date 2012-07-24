require_relative '../test_helper'

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
      assert_equal(I18n.t('bureaucrat.default_errors.fields.email.invalid'), @field.error_messages[:invalid])
    end
  end
end
