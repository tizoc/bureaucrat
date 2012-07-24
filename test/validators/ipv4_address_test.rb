require_relative '../test_helper'
require 'bureaucrat/validators/ipv4_address'

module TestValidators
  class Test_ValidateIPV4Address < BureaucratTestCase
    def test_translated_message
      Bureaucrat::Validators::ValidateIPV4Address.call(nil)
    rescue ValidationError => e
      assert_equal([I18n.t('bureaucrat.default_errors.validators.validate_ipv4_address')], e.messages)
    end
  end
end
