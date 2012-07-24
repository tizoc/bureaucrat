require_relative '../test_helper'
require 'bureaucrat/validators/min_length'

module TestValidators
  class Test_MinValueValidator < BureaucratTestCase
    def test_translated_message
      Bureaucrat::Validators::MinValueValidator.new(50).call(19)
    rescue Bureaucrat::ValidationError => e
      assert_equal(['Ensure this value is greater than or equal to 50.'], e.messages)
    end
  end
end
