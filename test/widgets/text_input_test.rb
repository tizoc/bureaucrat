require_relative '../test_helper'

module Widget
  class Test_TextInput_widget < BureaucratTestCase
    class Test_with_empty_attributes < BureaucratTestCase
      def test_correctly_render
        input = Bureaucrat::Widgets::TextInput.new
        expected = normalize_html('<input type="text" value="hi" name="test" />')
        rendered = normalize_html(input.render('test', 'hi'))
        assert_equal(expected, rendered)
      end
    end

    class Test_with_attributes < BureaucratTestCase
      def test_correctly_render
        input = Bureaucrat::Widgets::TextInput.new(attribute: 'value')
        expected = normalize_html('<input type="text" value="hi" name="test" attribute="value" />')
        rendered = normalize_html(input.render('test', 'hi'))
        assert_equal(expected, rendered)
      end
    end

    class Test_without_value < BureaucratTestCase
      def test_not_render_a_value
        input = Bureaucrat::Widgets::TextInput.new
        expected = normalize_html('<input type="text" name="test" />')
        rendered = normalize_html(input.render('test', nil))
        assert_equal(expected, rendered)
      end
    end

    class Test_when_copied < BureaucratTestCase
      def test_have_a_copy_of_the_attributes
        input1 = Bureaucrat::Widgets::TextInput.new(attribute: 2)
        input2 = input1.dup
        assert_not_equal(input1.attrs.object_id, input2.attrs.object_id)
      end
    end
  end
end
