require_relative '../test_helper'

module Widgets
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
