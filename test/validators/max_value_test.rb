require_relative '../test_helper'
require 'bureaucrat/validators/max_value'

module TestValidators
  class Test_MaxValueValidator < BureaucratTestCase
    def test_translated_message
      Bureaucrat::Validators::MaxValueValidator.new(20).call(21)
    rescue Bureaucrat::ValidationError => e
      assert_equal(['Ensure this value is less than or equal to 20.'], e.messages)
    end
  end
end
