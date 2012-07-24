require_relative '../test_helper'
require 'bureaucrat/validators/min_length'

module TestValidators
  class Test_MinLengthValidator < BureaucratTestCase
    def test_translated_message
      Bureaucrat::Validators::MinLengthValidator.new(3).call('12')
    rescue ValidationError => e
      assert_equal(['Ensure this value has at least 3 characters (it has 2).'], e.messages)
    end
  end
end
