require_relative '../test_helper'
require 'bureaucrat/validators/email'

module TestValidators
  class Test_ValidateEmail < BureaucratTestCase
    def test_translated_message
      Bureaucrat::Validators::ValidateEmail.call(nil)
    rescue ValidationError => e
      assert_equal([I18n.t('bureaucrat.default_errors.validators.validate_email')], e.messages)
    end
  end
end
