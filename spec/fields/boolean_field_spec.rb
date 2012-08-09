require 'bureaucrat/fields/boolean_field'

describe Bureaucrat::Fields::BooleanField do
  it 'has a default field' do
    field = described_class.new
    widget = field.default_widget
    widget.should be_a(Bureaucrat::Widgets::CheckboxInput)
  end

  it 'creates a widget with value 1' do
    field = described_class.new
    field.default_widget.attrs[:value].should == '1'
  end
end
