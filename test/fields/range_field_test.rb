require_relative '../test_helper'
require 'bureaucrat/fields/range_field'

module RangeFieldTest
  class Test_on_clean < BureaucratTestCase
    def setup
      @field = Bureaucrat::Fields::RangeField.new(max_value:10, min_value:1, required: false)
      @field.form_name = "blah_form"
      @field.name = "awesomeness"
    end

    def test_valid
      assert_nothing_raised do
        assert_equal({'max' => 5, 'min' => 2}, @field.clean({'max' => 5, 'min'=> 2}))
      end
    end

    def test_no_data
      assert_nothing_raised do
        @field.clean({'max' => nil, 'min' => nil})
      end
    end

    def test_min_field_present
      assert_raises(Bureaucrat::ValidationError) do
        @field.clean({'max' => 44, 'min' => nil})
      end
    end

    def test_max_field_present
      assert_raises(Bureaucrat::ValidationError) do
        @field.clean({'max' => nil, 'min' => 55})
      end
    end

    def test_reverses_min_and_max
      assert_raises(Bureaucrat::ValidationError) do
        @field.clean({'max' => 2, 'min'=> 5})
      end
    end

    def test_outside_range
      assert_raises(Bureaucrat::ValidationError) do
        @field.clean({'max' => 11, 'min' => 1})
      end
      assert_raises(Bureaucrat::ValidationError) do
        @field.clean({'max' => 10, 'min' => 0})
      end
    end

    def test_default_widget
      assert_equal @field.widget.class, Bureaucrat::Widgets::Range
    end

    def test_take_any_sub_field_class
      @field = Bureaucrat::Fields::RangeField.new(max_value:10, min_value:1, sub_field:Bureaucrat::Fields::FloatField)
      assert_equal({'max' => 5.6, 'min' => 2.2}, @field.clean({'max' => 5.6, 'min'=> 2.2}))
    end
  end
end
