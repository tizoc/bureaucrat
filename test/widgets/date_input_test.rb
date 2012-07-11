require_relative '../test_helper'

module Widget
  def test_correctly_render
    input = Widgets::DateInput.new(nil, '%Y/%m/%d')
    expected = normalize_html("<input name='test' type='text' value='1982/10/25' />")
    rendered = normalize_html(input.render('test', Date.parse('1982-10-25')))
    assert_equal(expected, rendered)
  end
end
