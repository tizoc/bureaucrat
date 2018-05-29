require 'bureaucrat/fields/boolean_field'

describe Bureaucrat::Fields::BooleanField do
  it 'has a default field' do
    field = described_class.new
    widget = field.default_widget
    expect(widget).to eq(Bureaucrat::Widgets::CheckboxInput)
  end

  it 'creates a widget with value 1' do
    field = described_class.new
    expect(field.widget.attrs[:value]).to eq('1')
  end
end
