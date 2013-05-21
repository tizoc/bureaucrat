require 'spec_helper'
require 'bureaucrat/fields/social_security_number_field'

describe Bureaucrat::Fields::SocialSecurityNumberField do
  let(:field) {Bureaucrat::Fields::SocialSecurityNumberField.new}

  [
    '123456789',
    '123-45-6789',
    '      123-45-6789      '
  ].each do |ssn|
    it "allows #{ssn}" do
      field.clean(ssn).should == ssn.strip
    end
  end


  context 'not allowed values' do
    it 'doesnt allow less than 9 characters' do
      expect{field.clean('12345678')}.to raise_error(Bureaucrat::ValidationError)
    end

    it 'doesnt allow more than 9 characters' do
      expect{field.clean('1234567890')}.to raise_error(Bureaucrat::ValidationError)
    end

    it 'only allows numeric digits' do
      expect{field.clean('12a456b89')}.to raise_error(Bureaucrat::ValidationError)
    end

    it 'doesnt allow invalid hyphen formats of an SSN' do
      expect{field.clean('123-3-34567')}.to raise_error(Bureaucrat::ValidationError)
    end
  end
end
