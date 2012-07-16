require_relative '../test_helper'
require 'bureaucrat/widgets/range'

module Widgets
  class Test_RangeWidget < BureaucratTestCase
    def test_range_widget
      range = Widgets::Range.new()
      html =  range.render("pay_range", {:min => 5, :max => 12}, {:seperator => "to", :suffix => "pairs of shoes"} )
      assert_equal("<input type=\"text\" name=\"pay_range[min]\" value=\"5\" /><input type=\"text\" name=\"pay_range[max]\" value=\"12\" />pairs of shoes", html)
    end
  end
end
