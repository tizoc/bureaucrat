require_relative '../test_helper'
require 'bureaucrat/widgets/range'

module Widgets
  class Test_RangeWidget < BureaucratTestCase
    def test_range_widget
      range = Widgets::Range.new({:seperator => "to", :suffix => "pairs of shoes"})
      html =  range.render("pay_range", {:min => 5, :max => 12} )
      assert_equal("<input type=\"text\" name=\"pay_range[min]\" value=\"5\" />  <input type=\"text\" name=\"pay_range[max]\" value=\"12\" /> pairs of shoes", html)
    end

    def test_works_with_a_field
      range = Widgets::Range.new()
      assert_nothing_raised {Bureaucrat::Fields::Field.new(:widget => range)}
    end

    class Foo
      def initialize(options)
      end

      def render(*args)
        "blagh"
      end
    end

    def test_takes_an_alternate_sub_widget
      range = Widgets::Range.new(:sub_widget_class => Foo)
      html =  range.render("pay_range", {:min => 5, :max => 12} )
      assert(html.include?("blagh"))
    end

  end
end
