require_relative '../test_helper'

module RangeFieldTest
  class Test_on_clean < BureaucratTestCase
    def setup
      @field = Fields::RangeField.new(max_value:10, min_value:1)
    end

    def test_valid
      assert_nothing_raised do
        assert_equal({:max => 5, :min => 2}, @field.clean({:max => 5, :min=> 2}))
      end
    end

    def test_reverses_min_and_max
        assert_equal({:max => 5, :min => 2}, @field.clean({:max => 2, :min=> 5}))
    end

    def test_outside_range
      assert_raises(ValidationError) do
        @field.clean({:max => 11, :min => 1})
      end
      assert_raises(ValidationError) do
        @field.clean({:max => 10, :min => 0})
      end
    end

    def test_default_widget
      assert_equal @field.widget.class, Bureaucrat::Widgets::Range
    end
  end
end
