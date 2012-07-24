require_relative '../test_helper'
require 'bureaucrat/widgets/file_input'

module WidgetTests
  class Test_FileInput_widget < BureaucratTestCase
    def test_correctly_render
      input = Widgets::FileInput.new
      expected = normalize_html("<input name='test' type='file'/>")
      rendered = normalize_html(input.render('test', "anything"))
      assert_equal(expected, rendered)
    end
    # TODO: value_from_datahash, has_changed?
  end

end
