require_relative '../test_helper'

module RangeFieldTest
  class Test_on_clean < BureaucratTestCase
    def setup
      @field = Fields::RangeField.new(max_value:10, min_value:1)
    end

    def test_valid
      assert_nothing_raised do
        assert_equal({:max => 5, :min => 2}, @field.clean([2, 5]))
      end
    end

    def test_outside_range
      assert_raises(ValidationError) do
        @field.clean([11, 1])
      end
      assert_raises(ValidationError) do
        @field.clean([10, 0])
      end
    end
  end
end
