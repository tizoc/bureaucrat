require File.dirname(__FILE__) + "/test_helper"

class TestWidgets < BureaucratTestCase
  describe 'TextInput widget' do

    describe 'with empty attributes' do
      should 'correctly render' do
        input = Widgets::TextInput.new
        expected = normalize_html('<input type="text" value="hi" name="test" />')
        rendered = normalize_html(input.render('test', 'hi'))
        assert_equal(expected, rendered)
      end
    end

    describe 'with attributes' do
      should 'correctly render' do
        input = Widgets::TextInput.new(:attribute => 'value')
        expected = normalize_html('<input type="text" value="hi" name="test" attribute="value" />')
        rendered = normalize_html(input.render('test', 'hi'))
        assert_equal(expected, rendered)
      end
    end

    describe 'without value' do
      should 'not render a value' do
        input = Widgets::TextInput.new
        expected = normalize_html('<input type="text" name="test" />')
        rendered = normalize_html(input.render('test', nil))
        assert_equal(expected, rendered)
      end
    end

    describe 'when copied' do
      should 'have a copy of the attributes' do
        input1 = Widgets::TextInput.new(:attribute => 2)
        input2 = input1.dup
        assert_not_equal(input1.attrs.object_id, input2.attrs.object_id)
      end
    end
  end

  describe 'PasswordInput widget' do
    describe 'with render_value=true' do
      should 'render correctly including value' do
        input = Widgets::PasswordInput.new(nil, true)
        expected = normalize_html("<input name='test' type='password' value='secret'/>")
        rendered = normalize_html(input.render('test', 'secret'))
        assert_equal(expected, rendered)
      end
    end

    describe 'with render_value=false' do
      should 'render correctly not including value' do
        input = Widgets::PasswordInput.new(nil, false)
        expected = normalize_html("<input name='test' type='password'/>")
        rendered = normalize_html(input.render('test', 'secret'))
        assert_equal(expected, rendered)
      end
    end
  end

  describe 'HiddenInput widget' do
    should 'correctly render' do
      input = Widgets::HiddenInput.new
      expected = normalize_html("<input name='test' type='hidden' value='secret'/>")
      rendered = normalize_html(input.render('test', 'secret'))
      assert_equal(expected, rendered)
    end
  end

  describe 'MultipleHiddenInput widget' do
    should 'correctly render' do
      input = Widgets::MultipleHiddenInput.new
      expected = normalize_html("<input name='test[]' type='hidden' value='v1'/>\n<input name='test[]' type='hidden' value='v2'/>")
      rendered = normalize_html(input.render('test', ['v1', 'v2']))
      assert_equal(expected, rendered)
    end
    # TODO: value_from_datahash
  end

  describe 'FileInput widget' do
    should 'correctly render' do
      input = Widgets::FileInput.new
      expected = normalize_html("<input name='test' type='file'/>")
      rendered = normalize_html(input.render('test', "anything"))
      assert_equal(expected, rendered)
    end
    # TODO: value_from_datahash, has_changed?
  end

  describe 'Textarea widget' do
    should 'correctly render' do
      input = Widgets::Textarea.new(:cols => '50', :rows => '15')
      expected = normalize_html("<textarea name='test' rows='15' cols='50'>hello</textarea>")
      rendered = normalize_html(input.render('test', "hello"))
      assert_equal(expected, rendered)
    end

    should 'correctly render multiline' do
      input = Widgets::Textarea.new(:cols => '50', :rows => '15')
      expected = normalize_html("<textarea name='test' rows='15' cols='50'>hello\n\ntest</textarea>")
      rendered = normalize_html(input.render('test', "hello\n\ntest"))
      assert_equal(expected, rendered)
    end
  end

  describe 'CheckboxInput widget' do
    should 'correctly render with a false value' do
      input = Widgets::CheckboxInput.new
      expected = normalize_html("<input name='test' type='checkbox'/>")
      rendered = normalize_html(input.render('test', false))
      assert_equal(expected, rendered)
    end

    should 'correctly render with a true value' do
      input = Widgets::CheckboxInput.new
      expected ="<input checked='checked' name='test' type='checkbox'/>"
      rendered = normalize_html(input.render('test', true))
      assert_equal(expected, rendered)
    end

    should 'correctly render with a non boolean value' do
      input = Widgets::CheckboxInput.new
      expected = "<input checked='checked' name='test' type='checkbox' value='anything'/>"
      rendered = normalize_html(input.render('test', 'anything'))
      assert_equal(expected, rendered)
    end
    # TODO: value_from_datahash, has_changed?
  end

  describe 'Select widget' do
    def setup
      @choices = [['1', 'One'], ['2', 'Two']]
      @groupchoices = [['numbers', ['1', 'One'], ['2', 'Two']],
                       ['words', [['spoon', 'Spoon'], ['banana', 'Banana']]]]
      @simplechoices = [ "able", "baker", "charlie" ]
      @optionchoices = [[{ :value => "foo", :disabled => "disabled", :onSelect => "doSomething();" }, "Foo"],
                        [{ :value => "bar" }, "Bar"]]
      @optionchoicesselected = [[{ :value => "foo", :disabled => "disabled" }, "Foo"],
                                [{ :value => "bar", :selected => "selected" }, "Bar"]]
    end

    describe 'with empty choices' do
      should 'correctly render' do
        input = Widgets::Select.new
        expected = normalize_html("<select name='test'>\n</select>")
        rendered = normalize_html(input.render('test', 'hello'))
        assert_equal(expected, rendered)
      end
    end

    describe 'with flat choices' do
      should 'correctly render (none selected)' do
        input = Widgets::Select.new(nil, @choices)
        expected = normalize_html("<select name='test'>\n<option value='1'>One</option>\n<option value='2'>Two</option>\n</select>")
        rendered = normalize_html(input.render('test', 'hello'))
        assert_equal(expected, rendered)
      end

      should 'correctly render (with selected)' do
        input = Widgets::Select.new(nil, @choices)
        expected = normalize_html("<select name='test'>\n<option value='1'>One</option>\n<option value='2' selected='selected'>Two</option>\n</select>")
        rendered = normalize_html(input.render('test', '2'))
        assert_equal(expected, rendered)
      end
    end

    describe 'with group choices' do
      should 'correctly render (none selected)' do
        input = Widgets::Select.new(nil, @groupchoices)
        expected = normalize_html("<select name='test'>\n<optgroup label='numbers'>\n<option value='1'/>\n<option value='One'/>\n</optgroup>\n<optgroup label='words'>\n<option value='spoon'>Spoon</option>\n<option value='banana'>Banana</option>\n</optgroup>\n</select>")
        rendered = normalize_html(input.render('test', 'hello'))
        assert_equal(expected, rendered)
      end

      should 'correctly render (with selected)' do
        input = Widgets::Select.new(nil, @groupchoices)
        expected = normalize_html("<select name='test'>\n<optgroup label='numbers'>\n<option value='1'/>\n<option value='One'/>\n</optgroup>\n<optgroup label='words'>\n<option value='spoon'>Spoon</option>\n<option value='banana' selected='selected'>Banana</option>\n</optgroup>\n</select>")
        rendered = normalize_html(input.render('test', 'banana'))
        assert_equal(expected, rendered)
      end
    end

    describe 'with simple choices' do
      should 'correctly render (none selected)' do
        input = Widgets::Select.new(nil, @simplechoices)
        expected = normalize_html("<select name='test'>\n<option value='able'>able</option>\n<option value='baker'>baker</option>\n<option value='charlie'>charlie</option>\n</select>")
        rendered = normalize_html(input.render('test', 'hello'))
        assert_equal(expected, rendered)
      end

      should 'correctly render (with selected)' do
        input = Widgets::Select.new(nil, @simplechoices)
        expected = normalize_html("<select name='test'>\n<option value='able'>able</option>\n<option value='baker' selected='selected'>baker</option>\n<option value='charlie'>charlie</option>\n</select>")
        rendered = normalize_html(input.render('test', 'baker'))
        assert_equal(expected, rendered)
      end
    end

    describe 'with option choices' do
      should 'correctly render (none selected)' do
        input = Widgets::Select.new(nil, @optionchoices)
        expected = normalize_html("<select name='test'>\n<option value='foo' disabled='disabled' onSelect='doSomething();'>Foo</option>\n<option value='bar'>Bar</option>\n</select>")
        rendered = normalize_html(input.render('test', 'hello'))
        assert_equal(expected, rendered)
      end

      should 'correctly render (traditional selected)' do
        input = Widgets::Select.new(nil, @optionchoices)
        expected = normalize_html("<select name='test'>\n<option value='foo' disabled='disabled' onSelect='doSomething();'>Foo</option>\n<option value='bar' selected='selected'>Bar</option>\n</select>")
        rendered = normalize_html(input.render('test', 'bar'))
        assert_equal(expected, rendered)
      end

      should 'correctly render (option selected)' do
        input = Widgets::Select.new(nil, @optionchoicesselected)
        expected = normalize_html("<select name='test'>\n<option value='foo' disabled='disabled'>Foo</option>\n<option value='bar' selected='selected'>Bar</option>\n</select>")
        rendered = normalize_html(input.render('test', 'hello'))
        assert_equal(expected, rendered)
      end
    end
  end

  describe 'NullBooleanSelect widget' do
    should 'correctly render with "Unknown" as the default value when none is selected' do
      input = Widgets::NullBooleanSelect.new
      expected = normalize_html("<select name='test'>\n<option selected='selected' value='1'>Unknown</option>\n<option value='2'>Yes</option>\n<option value='3'>No</option>\n</select>")
      rendered = normalize_html(input.render('test', nil))
      assert_equal(expected, rendered)
    end

    should 'correctly render (with selected)' do
      input = Widgets::NullBooleanSelect.new
      expected = normalize_html("<select name='test'>\n<option value='1'>Unknown</option>\n<option selected='selected' value='2'>Yes</option>\n<option value='3'>No</option>\n</select>")
      rendered = normalize_html(input.render('test', '2'))
      assert_equal(expected, rendered)
    end
  end

  describe 'SelectMultiple widget' do
    def setup
      @choices = [['1', 'One'], ['2', 'Two']]
      @groupchoices = [['numbers', ['1', 'One'], ['2', 'Two']],
                       ['words', [['spoon', 'Spoon'], ['banana', 'Banana']]]]
    end

    describe 'with empty choices' do
      should 'correctly render' do
        input = Widgets::SelectMultiple.new
        expected = normalize_html("<select name='test[]' multiple='multiple'>\n</select>")
        rendered = normalize_html(input.render('test', 'hello'))
        assert_equal(expected, rendered)
      end
    end

    describe 'with flat choices' do
      should 'correctly render (none selected)' do
        input = Widgets::SelectMultiple.new(nil, @choices)
        expected = normalize_html("<select name='test[]' multiple='multiple'>\n<option value='1'>One</option>\n<option value='2'>Two</option>\n</select>")
        rendered = normalize_html(input.render('test', 'hello'))
        assert_equal(expected, rendered)
      end

      should 'correctly render (with selected)' do
        input = Widgets::SelectMultiple.new(nil, @choices)
        expected = normalize_html("<select name='test[]' multiple='multiple'>\n<option value='1' selected='selected'>One</option>\n<option value='2' selected='selected'>Two</option>\n</select>")
        rendered = normalize_html(input.render('test', ['1', '2']))
        assert_equal(expected, rendered)
      end
    end

    describe 'with group choices' do
      should 'correctly render (none selected)' do
        input = Widgets::SelectMultiple.new(nil, @groupchoices)
        expected = normalize_html("<select name='test[]' multiple='multiple'>\n<optgroup label='numbers'>\n<option value='1'/>\n<option value='One'/>\n</optgroup>\n<optgroup label='words'>\n<option value='spoon'>Spoon</option>\n<option value='banana'>Banana</option>\n</optgroup>\n</select>")
        rendered = normalize_html(input.render('test', 'hello'))
        assert_equal(expected, rendered)
      end

      should 'correctly render (with selected)' do
        input = Widgets::SelectMultiple.new(nil, @groupchoices)
        expected = normalize_html("<select name='test[]' multiple='multiple'>\n<optgroup label='numbers'>\n<option value='1'/>\n<option value='One'/>\n</optgroup>\n<optgroup label='words'>\n<option value='spoon' selected='selected'>Spoon</option>\n<option value='banana' selected='selected'>Banana</option>\n</optgroup>\n</select>")
        rendered = normalize_html(input.render('test', ['banana', 'spoon']))
        assert_equal(expected, rendered)
      end
    end
  end

  describe "RadioSelect widget" do
    should 'correctly render (none selected)' do
      input = Widgets::RadioSelect.new(nil, [['1', 'One'], ['2', 'Two']])
      expected = normalize_html("<ul>\n<li><label for='id_radio_0'><input name='radio' id='id_radio_0' type='radio' value='1'/> One</label></li>\n<li><label for='id_radio_1'><input name='radio' id='id_radio_1' type='radio' value='2'/> Two</label></li>\n</ul>")
      rendered = normalize_html(input.render('radio', '', :id => 'id_radio'))
      assert_equal(expected, rendered)
    end

    should 'correctly render (with selected)' do
      input = Widgets::RadioSelect.new(nil, [['1', 'One'], ['2', 'Two']])
      expected = normalize_html("<ul>\n<li><label for='id_radio_0'><input checked='checked' name='radio' id='id_radio_0' type='radio' value='1'/> One</label></li>\n<li><label for='id_radio_1'><input name='radio' id='id_radio_1' type='radio' value='2'/> Two</label></li>\n</ul>")
      rendered = normalize_html(input.render('radio', '1', :id => 'id_radio'))
      assert_equal(expected, rendered)
    end
  end

  describe 'CheckboxSelectMultiple widget' do
    def setup
      @choices = [['1', 'One'], ['2', 'Two'], ['3', 'Three']]
    end

    describe 'with empty choices' do
      should 'render an empty ul' do
        input = Widgets::CheckboxSelectMultiple.new
        expected = normalize_html("<ul>\n</ul>")
        rendered = normalize_html(input.render('test', 'hello', :id => 'id_checkboxes'))
        assert_equal(expected, rendered)
      end
    end

    describe 'with choices' do
      should 'correctly render (none selected)' do
        input = Widgets::CheckboxSelectMultiple.new(nil, @choices)
        expected = normalize_html("<ul>\n<li><label for='id_checkboxes_0'><input name='test[]' id='id_checkboxes_0' type='checkbox' value='1'/> One</label></li>\n<li><label for='id_checkboxes_1'><input name='test[]' id='id_checkboxes_1' type='checkbox' value='2'/> Two</label></li>\n<li><label for='id_checkboxes_2'><input name='test[]' id='id_checkboxes_2' type='checkbox' value='3'/> Three</label></li>\n</ul>")
        rendered = normalize_html(input.render('test', 'hello', :id => 'id_checkboxes'))
        assert_equal(expected, rendered)
      end

      should 'correctly render (with selected)' do
        input = Widgets::CheckboxSelectMultiple.new(nil, @choices)
        expected = normalize_html("<ul>\n<li><label for='id_checkboxes_0'><input checked='checked' name='test[]' id='id_checkboxes_0' type='checkbox' value='1'/> One</label></li>\n<li><label for='id_checkboxes_1'><input checked='checked' name='test[]' id='id_checkboxes_1' type='checkbox' value='2'/> Two</label></li>\n<li><label for='id_checkboxes_2'><input name='test[]' id='id_checkboxes_2' type='checkbox' value='3'/> Three</label></li>\n</ul>")
        rendered = normalize_html(input.render('test', ['1', '2'],
                                               :id => 'id_checkboxes'))
        assert_equal(expected, rendered)
      end
    end
  end

end
