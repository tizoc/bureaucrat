require 'spec_helper'
require 'bureaucrat/fields/email_field'

describe Bureaucrat::Fields::EmailField do
  let(:field) {Bureaucrat::Fields::EmailField.new}

  [
    'myles@8thlight.com',
    'myles.megyesi@8thlight.com',
    'myles.megyesi@8thlight.blah.com',
    'm@8thlight.co',
    'myles@8thlight.org',
    '    myles@8thlight.com    ',
    'email@domain.com',
    'email+extra@domain.com',
    'email@domain.fm',
    'email@domain.co.uk'
  ].each do |email|
    it "passes for #{email.inspect}" do
      field.clean(email).should == email.strip
    end
  end

  [
    'myles8th.com',
    '@8thlight.com',
    'm@8thlight',
    'm@8thlight.c',
    '',
    nil,
    'banana',
    'spoon',
    'invalid@dom#ain.com',
    'invalid@@domain.com',
    'invalid@domain',
    'invalid@.com'
  ].each do |email|
    it "fails for #{email.inspect}" do
      expect {field.clean(email)}.to raise_error(Bureaucrat::ValidationError)
    end
  end

end
