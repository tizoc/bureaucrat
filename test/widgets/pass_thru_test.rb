require_relative '../test_helper'
require 'bureaucrat/widgets/pass_thru'

module Widget
  class Test_PassThru_widget < BureaucratTestCase
    def test_correctly_render
      input = Bureaucrat::Widgets::PassThru.new
      assert_equal(input.render('test', 'secret'), '')
    end
  end
end

