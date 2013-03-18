require_relative '../test_helper'
require 'bureaucrat/widgets/range'

module Widgets
  class Test_RangeWidget < BureaucratTestCase
    def test_range_widget
      range = Bureaucrat::Widgets::Range.new({:separator => "to", :prefix => 'I gots',:suffix => "pairs of shoes"})
      html =  range.render("pay_range", {'min' => 5, 'max' => 12}, {min: {class: 'my-class'}})
      assert_equal("<a name=\"pay_range\"></a>I gots <input type=\"text\" name=\"pay_range[min]\" class=\"my-class\" value=\"5\" /> to <input type=\"text\" name=\"pay_range[max]\" value=\"12\" /> pairs of shoes", html)
    end

    def test_works_with_a_field
      range = Bureaucrat::Widgets::Range.new
      assert_nothing_raised {Bureaucrat::Fields::Field.new(:widget => range)}
    end

    class Foo
      def initialize(options)
      end

      def render(*args)
        "blagh"
      end

      def value_from_formdata(data, name)
        return data[name]*100
      end

      def form_value(data, name)
        return data[name]*20
      end

    end

    def test_returns_string_access_hash
      range = Bureaucrat::Widgets::Range.new
      data = range.value_from_formdata({:name => {:min => 22, :max => 44}}, :name)
      assert(data.is_a?(Bureaucrat::Utils::StringAccessHash))
    end

    def test_takes_an_alternate_sub_widget
      range = Bureaucrat::Widgets::Range.new(:sub_widget_class => Foo)
      html =  range.render("pay_range", {:min => 5, :max => 12} )
      assert(html.include?("blagh"))
    end

    def test_converts_value_from_formdata
      range = Bureaucrat::Widgets::Range.new({:sub_widget_class => Foo, :separator => "to", :suffix => "pairs of shoes"})
      data = range.value_from_formdata({'rate' => {'min' => 12, 'max' => 20}}, 'rate')
      assert_equal 1200, data['min']
      assert_equal 2000, data['max']
    end

    def test_form_value_delegates_to_the_sub_widget
      range = Bureaucrat::Widgets::Range.new({:sub_widget_class => Foo, :separator => "to", :suffix => "pairs of shoes"})
      data = range.form_value({'rate' => {'min' => 12, 'max' => 20}}, 'rate')
      assert_equal 240, data['min']
      assert_equal 400, data['max']
    end

  end
end
