require 'spec_helper'
require 'bureaucrat/fields/phone_number_field'

describe Bureaucrat::Fields::PhoneNumberField do
  before :each do
    @field = Bureaucrat::Fields::PhoneNumberField.new
  end

  [
    '1-123-123-1234',
    '123-123-1234',
    '123-4438',
    '11231231234',
    '1231231234',
    '1234438',
    '1.123.123.1234',
    '123.123.1234',
    '123.4438'
  ].each do |phone_number|
    it "allows #{phone_number}" do
      @field.clean(phone_number).should == phone_number
    end
  end

  ['a', '1-789-67', '7644'].each do |phone_number|
    it "disallows #{phone_number}" do
      -> {@field.clean(phone_number)}.should raise_error(Bureaucrat::ValidationError)
    end
  end
end

