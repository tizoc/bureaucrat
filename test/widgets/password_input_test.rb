require_relative '../test_helper'
require 'bureaucrat/widgets/password_input'

module Widget
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
end
