require 'bureaucrat/widgets/currency_widget'

describe Bureaucrat::Widgets::CurrencyWidget do
  let(:widget) { described_class.new }

  it "displays cents and dollars" do
    expect(widget.render('name', 125, nil)).to be_include '1.25'
    expect(widget.render('name', 100, nil)).to be_include '1.00'
    expect(widget.render('name', nil, nil)).not_to be_include '0.00'
    expect(widget.render('name', '', nil)).not_to be_include '0.00'
    expect(widget.render('name', '1.001', nil)).to include '1.001'
  end

  it "converts formdata to a value" do
    expect(widget.value_from_formdata({"name" => "12.53"}, "name")).to eq(1253)
    expect(widget.value_from_formdata({"name" => "89.27"}, "name")).to eq(8927)
    expect(widget.value_from_formdata({"name" => "89"}, "name")).to eq(8900)
    expect(widget.value_from_formdata({"name" => "89."}, "name")).to eq(8900)
    expect(widget.value_from_formdata({"name" => "89.0"}, "name")).to eq(8900)
    expect(widget.value_from_formdata({"name" => "89.00"}, "name")).to eq(8900)
    expect(widget.value_from_formdata({"name" => "8900"}, "name")).to eq(890000)
    expect(widget.value_from_formdata({"name" => "-0.01"}, "name")).to eq(-1)
    expect(widget.value_from_formdata({"name" => "-12"}, "name")).to eq(-1200)
  end

  it 'accepts already-converted values (for repopulation)' do
    expect(widget.value_from_formdata({"name" => 1895}, "name")).to eq(1895)
  end

  it "leaves blank entries alone" do
    expect(widget.value_from_formdata({"name" => ""}, "name")).to eq("")
    expect(widget.value_from_formdata({"name" => nil}, "name")).to eq(nil)
  end

  it 'keeps original invalid values' do
    expect(widget.value_from_formdata({"name" => "something"}, "name")).to eq("something")
  end

  it "converts no-data to nil" do
    expect(widget.value_from_formdata({}, "name")).to be_nil
  end

  it 'allows dollar signs' do
    expect(widget.value_from_formdata({"name" => "$89.27"}, "name")).to eq(8927)
  end

  it 'disallows dollar signs in the middle' do
    expect(widget.value_from_formdata({"name" => "8$9.27"}, "name")).to eq("8$9.27")
  end

  it 'disallows 3 significant decimal places' do
    expect(widget.value_from_formdata({"name" => "1.001"}, "name")).to eq("1.001")
  end

  it 'allows trailing zeroes' do
    expect(widget.value_from_formdata({"name" => "15.000"}, "name")).to eq(1500)
  end

  it "doesn't change the data in the form" do
    data = {"name" => "12.53"}
    widget.value_from_formdata(data, "name")
    expect(data["name"]).to eq("12.53")
  end

  context '#form_value' do
    it 'returns the amount in dollars for a string' do
      expect(widget.form_value({"name" => "31.01"}, "name")).to eq('31.01')
    end

    it 'returns the amount in dollars for an amount in pennies' do
      expect(widget.form_value({"name" => 1895}, "name")).to eq('18.95')
    end

    it 'clears invalid data' do
      expect(widget.form_value({"name" => 'b3'}, "name")).to be_empty
    end
  end
end

