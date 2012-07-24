require_relative '../test_helper'
require 'bureaucrat/validators/max_length'

module TestValidators
  class Test_MaxLengthValidator < BureaucratTestCase
    def test_translated_message
      Bureaucrat::Validators::MaxLengthValidator.new(5).call('123456')
    rescue ValidationError => e
      assert_equal(['Ensure this value has at most 5 characters (it has 6).'], e.messages)
    end
  end
end
