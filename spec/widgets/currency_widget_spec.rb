require 'bureaucrat/widgets/currency_widget'

describe Bureaucrat::Widgets::CurrencyWidget do
  let(:widget) { described_class.new }

  it "displays cents and dollars" do
    widget.render('name', 125, nil).should be_include '1.25'
    widget.render('name', 100, nil).should be_include '1.00'
    widget.render('name', nil, nil).should_not be_include '0.00'
    widget.render('name', '', nil).should_not be_include '0.00'
  end

  it "converts formdata to a value" do
    widget.value_from_formdata({"name" => "12.53"}, "name").should == 1253
    widget.value_from_formdata({"name" => "89.27"}, "name").should == 8927
    widget.value_from_formdata({"name" => "89"}, "name").should == 8900
    widget.value_from_formdata({"name" => "89."}, "name").should == 8900
    widget.value_from_formdata({"name" => "89.0"}, "name").should == 8900
    widget.value_from_formdata({"name" => "89.00"}, "name").should == 8900
    widget.value_from_formdata({"name" => "8900"}, "name").should == 890000
    widget.value_from_formdata({"name" => "-0.01"}, "name").should == -1
    widget.value_from_formdata({"name" => "-12"}, "name").should == -1200
  end

  it 'accepts already-converted values (for repopulation)' do
    widget.value_from_formdata({"name" => 1895}, "name").should == 1895
  end

  it "leaves blank entries alone" do
    widget.value_from_formdata({"name" => ""}, "name").should == ""
    widget.value_from_formdata({"name" => nil}, "name").should == nil
  end

  it 'keeps original invalid values' do
    widget.value_from_formdata({"name" => "something"}, "name").should == "something"
  end

  it "converts no-data to nil" do
    widget.value_from_formdata({}, "name").should be_nil
  end

  it 'allows dollar signs' do
    widget.value_from_formdata({"name" => "$89.27"}, "name").should == 8927
  end

  it 'disallows dollar signs in the middle' do
    widget.value_from_formdata({"name" => "8$9.27"}, "name").should == "8$9.27"
  end

  it 'disallows 3 decimal places' do
    widget.value_from_formdata({"name" => "1.001"}, "name").should == "1.001"
  end

  it "doesn't change the data in the form" do
    data = {"name" => "12.53"}
    widget.value_from_formdata(data, "name")
    data["name"].should == "12.53"
  end

  context '#form_value' do
    it 'returns the amount in dollars for a string' do
      widget.form_value({"name" => "31.01"}, "name").should == '31.01'
    end

    it 'returns the amount in dollars for an amount in pennies' do
      widget.form_value({"name" => 1895}, "name").should == '18.95'
    end

    it 'clears invalid data' do
      widget.form_value({"name" => 'b3'}, "name").should be_empty
    end
  end
end

