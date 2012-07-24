require_relative '../test_helper'
require 'bureaucrat/validators/slug'

module TestValidators
  class Test_ValidateSlug < BureaucratTestCase
    def test_translated_message
      Bureaucrat::Validators::ValidateSlug.call(nil)
    rescue ValidationError => e
      assert_equal([I18n.t('bureaucrat.default_errors.validators.validate_slug')], e.messages)
    end
  end
end
