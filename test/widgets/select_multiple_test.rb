require_relative '../test_helper'

module Widget
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
end
