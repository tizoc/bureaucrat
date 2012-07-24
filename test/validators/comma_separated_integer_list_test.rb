require_relative '../test_helper'
require 'bureaucrat/validators/comma_separated_integer_list'

module TestValidators
  class Test_ValidateCommaSeparatedIntegerList < BureaucratTestCase
    def test_translated_message
      Bureaucrat::Validators::ValidateCommaSeparatedIntegerList.call(nil)
    rescue ValidationError => e
      assert_equal([I18n.t('bureaucrat.default_errors.validators.validate_comma_separated_integer_list')], e.messages)
    end
  end
end
