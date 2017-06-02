require 'bureaucrat/fields/currency_field'

describe Bureaucrat::Fields::CurrencyField do
  before :each do
    @field = described_class.new
  end

  it 'allows dollar signs' do
    expect(@field.clean('$123')).to eq(123)
  end

  it 'disallows dollar signs in the middle' do
    expect {@field.clean('1$4.98')}.to raise_error(Bureaucrat::ValidationError)
  end

  it 'disallows e-notation' do
    expect {@field.clean('1300e-2')}.to raise_error(Bureaucrat::ValidationError)
  end

  it 'disallows 3 significant decimal places' do
    expect {@field.clean('1.001')}.to raise_error(Bureaucrat::ValidationError)
  end

  it 'allows trailing zeroes' do
    expect {@field.clean('15.000')}.not_to raise_error
  end

  it 'handles nil' do
    expect {@field.clean(nil)}.to raise_error(Bureaucrat::ValidationError)
  end

  it 'handles nil if not required' do
    field = described_class.new(required: false)
    expect(field.clean(nil)).to be_nil
  end

  it 'handles min and max cents' do
    field = described_class.new(:min_dollars => 2.00, :max_dollars => 6.00)
    expect {field.clean(50)}.to raise_error(Bureaucrat::ValidationError)
    expect {field.clean(750)}.to raise_error(Bureaucrat::ValidationError)
  end
end

