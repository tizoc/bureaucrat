require_relative '../test_helper'
require 'bureaucrat/validators/base'

module TestValidators
  class Test_BaseValidator < BureaucratTestCase
    def test_translated_message
      Bureaucrat::Validators::BaseValidator.new('18').call('john')
    rescue Bureaucrat::ValidationError => e
      assert_equal(['Ensure this value is 18 (it is john).'], e.messages)
    end

    def test_validator_can_take_a_formatter_lambda_for_displaying_data
      formatter = lambda { |val| val + 's' }
      Bureaucrat::Validators::BaseValidator.new('banana', formatter).call('john')
    rescue Bureaucrat::ValidationError => e
      assert_equal(['Ensure this value is bananas (it is john).'], e.messages)
    end
  end
end
