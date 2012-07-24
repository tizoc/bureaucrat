require_relative '../test_helper'
require 'bureaucrat/widgets/multiple_hidden_input'

module Widget
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
end
