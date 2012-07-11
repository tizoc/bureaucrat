require_relative '../test_helper'

module Widget
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

  module SelectTests
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
end
