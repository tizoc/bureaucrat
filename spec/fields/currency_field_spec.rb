require 'bureaucrat/fields/currency_field'

describe Bureaucrat::Fields::CurrencyField do
  before :each do
    @field = described_class.new
  end

  it 'allows dollar signs' do
    @field.clean('123').should == 123
  end

  it 'disallows dollar signs in the middle' do
    -> {@field.clean('1$4.98')}.should raise_error(Bureaucrat::ValidationError)
  end

  it 'disallows 3 decimal places' do
    -> {@field.clean('1.001')}.should raise_error(Bureaucrat::ValidationError)
  end

  it 'handles nil' do
    -> {@field.clean(nil)}.should raise_error(Bureaucrat::ValidationError)
  end

  it 'handles min and max cents' do
    field = described_class.new(:min_dollars => 2.00, :max_dollars => 6.00)
    -> {field.clean(50)}.should raise_error(Bureaucrat::ValidationError)
    -> {field.clean(750)}.should raise_error(Bureaucrat::ValidationError)
  end
end

