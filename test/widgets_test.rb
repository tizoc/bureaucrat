require_relative 'test_helper'

module WidgetTests
  class Test_TextInput_widget < BureaucratTestCase
    class Test_with_empty_attributes < BureaucratTestCase
      def test_correctly_render
        input = Widgets::TextInput.new
        expected = normalize_html('<input type="text" value="hi" name="test" />')
        rendered = normalize_html(input.render('test', 'hi'))
        assert_equal(expected, rendered)
      end
    end

    class Test_with_attributes < BureaucratTestCase
      def test_correctly_render
        input = Widgets::TextInput.new(attribute: 'value')
        expected = normalize_html('<input type="text" value="hi" name="test" attribute="value" />')
        rendered = normalize_html(input.render('test', 'hi'))
        assert_equal(expected, rendered)
      end
    end

    class Test_without_value < BureaucratTestCase
      def test_not_render_a_value
        input = Widgets::TextInput.new
        expected = normalize_html('<input type="text" name="test" />')
        rendered = normalize_html(input.render('test', nil))
        assert_equal(expected, rendered)
      end
    end

    class Test_when_copied < BureaucratTestCase
      def test_have_a_copy_of_the_attributes
        input1 = Widgets::TextInput.new(attribute: 2)
        input2 = input1.dup
        assert_not_equal(input1.attrs.object_id, input2.attrs.object_id)
      end
    end
  end

  class Test_PasswordInput_widget < BureaucratTestCase
    class Test_with_render_value_true < BureaucratTestCase
      def test_render_correctly_including_value
        input = Widgets::PasswordInput.new(nil, true)
        expected = normalize_html("<input name='test' type='password' value='secret'/>")
        rendered = normalize_html(input.render('test', 'secret'))
        assert_equal(expected, rendered)
      end
    end

    class Test_with_render_value_false < BureaucratTestCase
      def test_render_correctly_not_including_value
        input = Widgets::PasswordInput.new(nil, false)
        expected = normalize_html("<input name='test' type='password'/>")
        rendered = normalize_html(input.render('test', 'secret'))
        assert_equal(expected, rendered)
      end
    end
  end

  class Test_HiddenInput_widget < BureaucratTestCase
    def test_correctly_render
      input = Widgets::HiddenInput.new
      expected = normalize_html("<input name='test' type='hidden' value='secret'/>")
      rendered = normalize_html(input.render('test', 'secret'))
      assert_equal(expected, rendered)
    end
  end

  class Test_MultipleHiddenInput_widget < BureaucratTestCase
    def test_correctly_render
      input = Widgets::MultipleHiddenInput.new
      expected = normalize_html("<input name='test[]' type='hidden' value='v1'/>\n<input name='test[]' type='hidden' value='v2'/>")
      rendered = normalize_html(input.render('test', ['v1', 'v2']))
      assert_equal(expected, rendered)
    end
    # TODO: value_from_datahash
  end

  class Test_FileInput_widget < BureaucratTestCase
    def test_correctly_render
      input = Widgets::FileInput.new
      expected = normalize_html("<input name='test' type='file'/>")
      rendered = normalize_html(input.render('test', "anything"))
      assert_equal(expected, rendered)
    end
    # TODO: value_from_datahash, has_changed?
  end

  class Test_Textarea_widget < BureaucratTestCase
    def test_correctly_render
      input = Widgets::Textarea.new(cols: '50', rows: '15')
      expected = normalize_html("<textarea name='test' rows='15' cols='50'>hello</textarea>")
      rendered = normalize_html(input.render('test', "hello"))
      assert_equal(expected, rendered)
    end

    def test_correctly_render_multiline
      input = Widgets::Textarea.new(cols: '50', rows: '15')
      expected = normalize_html("<textarea name='test' rows='15' cols='50'>hello\n\ntest</textarea>")
      rendered = normalize_html(input.render('test', "hello\n\ntest"))
      assert_equal(expected, rendered)
    end
  end

  class Test_DateInput_widget < BureaucratTestCase
    def test_correctly_render
      input = Widgets::DateInput.new(nil, '%Y/%m/%d')
      expected = normalize_html("<input name='test' type='text' value='1982/10/25' />")
      rendered = normalize_html(input.render('test', Date.parse('1982-10-25')))
      assert_equal(expected, rendered)
    end
  end

  class Test_CheckboxInput_widget < BureaucratTestCase
    def test_correctly_render_with_a_false_value
      input = Widgets::CheckboxInput.new
      expected = normalize_html("<input name='test' type='checkbox'/>")
      rendered = normalize_html(input.render('test', false))
      assert_equal(expected, rendered)
    end

    def test_correctly_render_with_a_true_value
      input = Widgets::CheckboxInput.new
      expected ="<input checked='checked' name='test' type='checkbox'/>"
      rendered = normalize_html(input.render('test', true))
      assert_equal(expected, rendered)
    end

    def test_correctly_render_with_a_non_boolean_value
      input = Widgets::CheckboxInput.new
      expected = "<input checked='checked' name='test' type='checkbox' value='anything'/>"
      rendered = normalize_html(input.render('test', 'anything'))
      assert_equal(expected, rendered)
    end
    # TODO: value_from_datahash, has_changed?
  end

  module SelectWidgetTests
    class Test_with_empty_choices < BureaucratTestCase
      def test_correctly_render
        input = Widgets::Select.new
        expected = normalize_html("<select name='test'>\n</select>")
        rendered = normalize_html(input.render('test', 'hello'))
        assert_equal(expected, rendered)
      end
    end

    class Test_with_flat_choices < BureaucratTestCase
      def setup
        @choices = [['1', 'One'], ['2', 'Two']]
      end

      def test_correctly_render_none_selected
        input = Widgets::Select.new(nil, @choices)
        expected = normalize_html("<select name='test'>\n<option value='1'>One</option>\n<option value='2'>Two</option>\n</select>")
        rendered = normalize_html(input.render('test', 'hello'))
        assert_equal(expected, rendered)
      end

      def test_correctly_render_with_selected
        input = Widgets::Select.new(nil, @choices)
        expected = normalize_html("<select name='test'>\n<option value='1'>One</option>\n<option value='2' selected='selected'>Two</option>\n</select>")
        rendered = normalize_html(input.render('test', '2'))
        assert_equal(expected, rendered)
      end
    end

    class Test_with_group_choices < BureaucratTestCase
      def setup
        @groupchoices = [['numbers', ['1', 'One'], ['2', 'Two']],
                         ['words', [['spoon', 'Spoon'], ['banana', 'Banana']]]]
      end

      def test_correctly_render_none_selected
        input = Widgets::Select.new(nil, @groupchoices)
        expected = normalize_html("<select name='test'>\n<optgroup label='numbers'>\n<option value='1'/>\n<option value='One'/>\n</optgroup>\n<optgroup label='words'>\n<option value='spoon'>Spoon</option>\n<option value='banana'>Banana</option>\n</optgroup>\n</select>")
        rendered = normalize_html(input.render('test', 'hello'))
        assert_equal(expected, rendered)
      end

      def test_correctly_render_with_selected
        input = Widgets::Select.new(nil, @groupchoices)
        expected = normalize_html("<select name='test'>\n<optgroup label='numbers'>\n<option value='1'/>\n<option value='One'/>\n</optgroup>\n<optgroup label='words'>\n<option value='spoon'>Spoon</option>\n<option value='banana' selected='selected'>Banana</option>\n</optgroup>\n</select>")
        rendered = normalize_html(input.render('test', 'banana'))
        assert_equal(expected, rendered)
      end
    end

    class Test_with_simple_choices < BureaucratTestCase
      def setup
        @simplechoices = [ "able", "baker", "charlie" ]
      end

      def test_correctly_render_none_selected
        input = Widgets::Select.new(nil, @simplechoices)
        expected = normalize_html("<select name='test'>\n<option value='able'>able</option>\n<option value='baker'>baker</option>\n<option value='charlie'>charlie</option>\n</select>")
        rendered = normalize_html(input.render('test', 'hello'))
        assert_equal(expected, rendered)
      end

      def test_correctly_render_with_selected
        input = Widgets::Select.new(nil, @simplechoices)
        expected = normalize_html("<select name='test'>\n<option value='able'>able</option>\n<option value='baker' selected='selected'>baker</option>\n<option value='charlie'>charlie</option>\n</select>")
        rendered = normalize_html(input.render('test', 'baker'))
        assert_equal(expected, rendered)
      end
    end

    class Test_with_option_choices < BureaucratTestCase
      def setup
        @optionchoices = [[{ value: "foo", disabled: "disabled", onSelect: "doSomething();" }, "Foo"],
                          [{ value: "bar" }, "Bar"]]
        @optionchoicesselected = [[{ value: "foo", disabled: "disabled" }, "Foo"],
                                  [{ value: "bar", selected: "selected" }, "Bar"]]
      end

      def test_correctly_render_none_selected
        input = Widgets::Select.new(nil, @optionchoices)
        expected = normalize_html("<select name='test'>\n<option value='foo' disabled='disabled' onSelect='doSomething();'>Foo</option>\n<option value='bar'>Bar</option>\n</select>")
        rendered = normalize_html(input.render('test', 'hello'))
        assert_equal(expected, rendered)
      end

      def test_correctly_render_traditional_selected
        input = Widgets::Select.new(nil, @optionchoices)
        expected = normalize_html("<select name='test'>\n<option value='foo' disabled='disabled' onSelect='doSomething();'>Foo</option>\n<option value='bar' selected='selected'>Bar</option>\n</select>")
        rendered = normalize_html(input.render('test', 'bar'))
        assert_equal(expected, rendered)
      end

      def test_correctly_render_option_selected
        input = Widgets::Select.new(nil, @optionchoicesselected)
        expected = normalize_html("<select name='test'>\n<option value='foo' disabled='disabled'>Foo</option>\n<option value='bar' selected='selected'>Bar</option>\n</select>")
        rendered = normalize_html(input.render('test', 'hello'))
        assert_equal(expected, rendered)
      end
    end
  end

  class Test_NullBooleanSelect_widget < BureaucratTestCase
    def test_correctly_render_with_Unknown_as_the_default_value_when_none_is_selected
      input = Widgets::NullBooleanSelect.new
      expected = normalize_html("<select name='test'>\n<option selected='selected' value='1'>Unknown</option>\n<option value='2'>Yes</option>\n<option value='3'>No</option>\n</select>")
      rendered = normalize_html(input.render('test', nil))
      assert_equal(expected, rendered)
    end

    def test_correctly_render_with_selected
      input = Widgets::NullBooleanSelect.new
      expected = normalize_html("<select name='test'>\n<option value='1'>Unknown</option>\n<option selected='selected' value='2'>Yes</option>\n<option value='3'>No</option>\n</select>")
      rendered = normalize_html(input.render('test', '2'))
      assert_equal(expected, rendered)
    end
  end

  module SelectMultipleTests
    class Test_with_empty_choices < BureaucratTestCase
      def test_correctly_render
        input = Widgets::SelectMultiple.new
        expected = normalize_html("<select name='test[]' multiple='multiple'>\n</select>")
        rendered = normalize_html(input.render('test', ['hello']))
        assert_equal(expected, rendered)
      end
    end

    class Test_with_flat_choices < BureaucratTestCase
      def setup
        @choices = [['1', 'One'], ['2', 'Two']]
      end

      def test_correctly_render_none_selected
        input = Widgets::SelectMultiple.new(nil, @choices)
        expected = normalize_html("<select name='test[]' multiple='multiple'>\n<option value='1'>One</option>\n<option value='2'>Two</option>\n</select>")
        rendered = normalize_html(input.render('test', ['hello']))
        assert_equal(expected, rendered)
      end

      def test_correctly_render_with_selected
        input = Widgets::SelectMultiple.new(nil, @choices)
        expected = normalize_html("<select name='test[]' multiple='multiple'>\n<option value='1' selected='selected'>One</option>\n<option value='2' selected='selected'>Two</option>\n</select>")
        rendered = normalize_html(input.render('test', ['1', '2']))
        assert_equal(expected, rendered)
      end
    end

    class Test_with_group_choices < BureaucratTestCase
      def setup
        @groupchoices = [['numbers', ['1', 'One'], ['2', 'Two']],
                         ['words', [['spoon', 'Spoon'], ['banana', 'Banana']]]]
      end

      def test_correctly_render_none_selected
        input = Widgets::SelectMultiple.new(nil, @groupchoices)
        expected = normalize_html("<select name='test[]' multiple='multiple'>\n<optgroup label='numbers'>\n<option value='1'/>\n<option value='One'/>\n</optgroup>\n<optgroup label='words'>\n<option value='spoon'>Spoon</option>\n<option value='banana'>Banana</option>\n</optgroup>\n</select>")
        rendered = normalize_html(input.render('test', ['hello']))
        assert_equal(expected, rendered)
      end

      def test_correctly_render_with_selected
        input = Widgets::SelectMultiple.new(nil, @groupchoices)
        expected = normalize_html("<select name='test[]' multiple='multiple'>\n<optgroup label='numbers'>\n<option value='1'/>\n<option value='One'/>\n</optgroup>\n<optgroup label='words'>\n<option value='spoon' selected='selected'>Spoon</option>\n<option value='banana' selected='selected'>Banana</option>\n</optgroup>\n</select>")
        rendered = normalize_html(input.render('test', ['banana', 'spoon']))
        assert_equal(expected, rendered)
      end
    end
  end

  class Test_RadioSelect_widget < BureaucratTestCase
    def test_correctly_render_none_selected
      input = Widgets::RadioSelect.new(nil, [['1', 'One'], ['2', 'Two']])
      expected = normalize_html("<ul>\n<li><label for='id_radio_0'><input name='radio' id='id_radio_0' type='radio' value='1'/> One</label></li>\n<li><label for='id_radio_1'><input name='radio' id='id_radio_1' type='radio' value='2'/> Two</label></li>\n</ul>")
      rendered = normalize_html(input.render('radio', '', id: 'id_radio'))
      assert_equal(expected, rendered)
    end

    def test_correctly_render_with_selected
      input = Widgets::RadioSelect.new(nil, [['1', 'One'], ['2', 'Two']])
      expected = normalize_html("<ul>\n<li><label for='id_radio_0'><input checked='checked' name='radio' id='id_radio_0' type='radio' value='1'/> One</label></li>\n<li><label for='id_radio_1'><input name='radio' id='id_radio_1' type='radio' value='2'/> Two</label></li>\n</ul>")
      rendered = normalize_html(input.render('radio', '1', id: 'id_radio'))
      assert_equal(expected, rendered)
    end
  end

  module CheckboxSelectMultipleTests
    class Test_with_empty_choices < BureaucratTestCase
      def test_render_an_empty_ul
        input = Widgets::CheckboxSelectMultiple.new
        expected = normalize_html("<ul>\n</ul>")
        rendered = normalize_html(input.render('test', ['hello'], id: 'id_checkboxes'))
        assert_equal(expected, rendered)
      end
    end

    class Test_with_choices < BureaucratTestCase
      def setup
        @choices = [['1', 'One'], ['2', 'Two'], ['3', 'Three']]
      end

      def test_correctly_renders_none_selected
        input = Widgets::CheckboxSelectMultiple.new(nil, @choices)
        expected = normalize_html("<ul>\n<li><label for='id_checkboxes_0'><input name='test[]' id='id_checkboxes_0' type='checkbox' value='1'/> One</label></li>\n<li><label for='id_checkboxes_1'><input name='test[]' id='id_checkboxes_1' type='checkbox' value='2'/> Two</label></li>\n<li><label for='id_checkboxes_2'><input name='test[]' id='id_checkboxes_2' type='checkbox' value='3'/> Three</label></li>\n</ul>")
        rendered = normalize_html(input.render('test', ['hello'], id: 'id_checkboxes'))
        assert_equal(expected, rendered)
      end

      def test_correctly_renders_with_selected
        input = Widgets::CheckboxSelectMultiple.new(nil, @choices)
        expected = normalize_html("<ul>\n<li><label for='id_checkboxes_0'><input checked='checked' name='test[]' id='id_checkboxes_0' type='checkbox' value='1'/> One</label></li>\n<li><label for='id_checkboxes_1'><input checked='checked' name='test[]' id='id_checkboxes_1' type='checkbox' value='2'/> Two</label></li>\n<li><label for='id_checkboxes_2'><input name='test[]' id='id_checkboxes_2' type='checkbox' value='3'/> Three</label></li>\n</ul>")
        rendered = normalize_html(input.render('test', ['1', '2'],
                                               id: 'id_checkboxes'))
        assert_equal(expected, rendered)
      end
    end
  end

end
