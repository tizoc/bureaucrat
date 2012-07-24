require_relative '../test_helper'
require 'bureaucrat/validators/base'

module TestValidators
  class Test_BaseValidator < BureaucratTestCase
    def test_translated_message
      Bureaucrat::Validators::BaseValidator.new('18').call('john')
    rescue ValidationError => e
      assert_equal(['Ensure this value is 18 (it is john).'], e.messages)
    end
  end
end
