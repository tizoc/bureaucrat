require_relative '../test_helper'
require 'bureaucrat/widgets/radio_select'

module Widget
  class Test_RadioSelect_widget < BureaucratTestCase
    def test_correctly_render_none_selected
      input = Bureaucrat::Widgets::RadioSelect.new(nil, [['1', 'One'], ['2', 'Two']])
      expected = normalize_html("<ul>\n<li><label for='id_radio_0'><input name='radio' id='id_radio_0' type='radio' value='1'/> One</label></li>\n<li><label for='id_radio_1'><input name='radio' id='id_radio_1' type='radio' value='2'/> Two</label></li>\n</ul>")
      rendered = normalize_html(input.render('radio', '', id: 'id_radio'))
      assert_equal(expected, rendered)
    end

    def test_correctly_render_with_selected
      input = Bureaucrat::Widgets::RadioSelect.new(nil, [['1', 'One'], ['2', 'Two']])
      expected = normalize_html("<ul>\n<li><label for='id_radio_0'><input checked='checked' name='radio' id='id_radio_0' type='radio' value='1'/> One</label></li>\n<li><label for='id_radio_1'><input name='radio' id='id_radio_1' type='radio' value='2'/> Two</label></li>\n</ul>")
      rendered = normalize_html(input.render('radio', '1', id: 'id_radio'))
      assert_equal(expected, rendered)
    end

    def test_correctly_render_with_false_selected
      input = Bureaucrat::Widgets::RadioSelect.new(nil, [[true, 'True'], [false, 'False']])
      expected = normalize_html("<ul>\n<li><label for='id_radio_0'><input name='radio' id='id_radio_0' type='radio' value='true'/> True</label></li>\n<li><label for='id_radio_1'><input checked='checked' name='radio' id='id_radio_1' type='radio' value='false'/> False</label></li>\n</ul>")
      rendered = normalize_html(input.render('radio', false, id: 'id_radio'))
      assert_equal(expected, rendered)
    end

    def test_can_take_li_attrs
      input = Bureaucrat::Widgets::RadioSelect.new({li_attrs: {class: 'howdy'}}, [[true, 'True'], [false, 'False']])
      expected = normalize_html("<ul>\n<li class='howdy'><label for='id_radio_0'><input name='radio' id='id_radio_0' type='radio' value='true'/> True</label></li>\n<li class='howdy'><label for='id_radio_1'><input checked='checked' name='radio' id='id_radio_1' type='radio' value='false'/> False</label></li>\n</ul>")
      rendered = normalize_html(input.render('radio', false, id: 'id_radio'))
      assert_equal(expected, rendered)
    end

    def test_can_take_label_attrs
      input = Bureaucrat::Widgets::RadioSelect.new({label_attrs: {class: 'howdy'}}, [[true, 'True'], [false, 'False']])
      expected = normalize_html("<ul>\n<li><label for='id_radio_0' class='howdy'><input name='radio' id='id_radio_0' type='radio' value='true'/> True</label></li>\n<li><label for='id_radio_1' class='howdy'><input checked='checked' name='radio' id='id_radio_1' type='radio' value='false'/> False</label></li>\n</ul>")
      rendered = normalize_html(input.render('radio', false, id: 'id_radio'))
      assert_equal(expected, rendered)
    end
  end
end
