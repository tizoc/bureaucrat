require 'spec_helper'
require 'bureaucrat/fields/slug_field'

describe Bureaucrat::Fields::SlugField do
  let(:field) {Bureaucrat::Fields::SlugField.new}

  %w(abc
    -abc
    abc-
    abc-abc
    -abc-abc-).each do |slug|
    it "passes for #{slug.inspect}" do
      expect(field.clean(slug)).to eq(slug.strip)
    end
  end

  [
    '',
    nil
  ].each do |slug|
    it "fails for #{slug.inspect}" do
      expect {field.clean(slug)}.to raise_error(Bureaucrat::ValidationError)
    end
  end
end
