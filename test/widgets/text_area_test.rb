require_relative '../test_helper'

module Widget
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
end



