require 'bureaucrat/widgets/checkbox_select_multiple'

describe Bureaucrat::Widgets::CheckboxSelectMultiple do

  it "renders the widget" do
    widget = described_class.new(nil, ['blah', 'blee', 'bloo'])
    expect(widget.render('something', ['blah'], {id: 'hi'})).to eq(
      "<ul>\n<li><label for=\"hi_0\">" +
      "<input name=\"something[]\" id=\"hi_0\" type=\"checkbox\" checked=\"checked\" value=\"blah\" />" +
      " </label></li>\n" +
      "<li><label for=\"hi_1\">" +
      "<input name=\"something[]\" id=\"hi_1\" type=\"checkbox\" value=\"blee\" />" +
      " </label></li>\n" +
      "<li><label for=\"hi_2\">" +
      "<input name=\"something[]\" id=\"hi_2\" type=\"checkbox\" value=\"bloo\" />" +
      " </label></li>\n</ul>"
    )
  end

  it 'renders the widget into the given number of lists' do
    widget = described_class.new({columns: 2}, ['blah', 'blee', 'bloo'])
    expect(widget.render('something', ['blah'], {id: 'hi'})).to eq(
      "<ul class=\"column-0\">\n<li><label for=\"hi_0\">" +
      "<input name=\"something[]\" id=\"hi_0\" type=\"checkbox\" checked=\"checked\" value=\"blah\" />" +
      " </label></li>\n" +
      "<li><label for=\"hi_1\">" +
      "<input name=\"something[]\" id=\"hi_1\" type=\"checkbox\" value=\"blee\" />" +
      " </label></li>\n" +
      "</ul>\n<ul class=\"column-1\">\n" +
      "<li><label for=\"hi_2\">" +
      "<input name=\"something[]\" id=\"hi_2\" type=\"checkbox\" value=\"bloo\" />" +
      " </label></li>\n</ul>"
    )
  end

  it 'renders the widget into the given number of lists evenly' do
    widget = described_class.new({columns: 2}, ['blah', 'blee', 'bloo', 'blargh'])
    expect(widget.render('something', ['blah'], {id: 'hi'})).to eq(
      "<ul class=\"column-0\">\n<li><label for=\"hi_0\">" +
      "<input name=\"something[]\" id=\"hi_0\" type=\"checkbox\" checked=\"checked\" value=\"blah\" />" +
      " </label></li>\n" +
      "<li><label for=\"hi_1\">" +
      "<input name=\"something[]\" id=\"hi_1\" type=\"checkbox\" value=\"blee\" />" +
      " </label></li>\n" +
      "</ul>\n<ul class=\"column-1\">\n" +
      "<li><label for=\"hi_2\">" +
      "<input name=\"something[]\" id=\"hi_2\" type=\"checkbox\" value=\"bloo\" />" +
      " </label></li>\n" +
      "<li><label for=\"hi_3\">" +
      "<input name=\"something[]\" id=\"hi_3\" type=\"checkbox\" value=\"blargh\" />" +
      " </label></li>\n</ul>"
    )
  end
end
