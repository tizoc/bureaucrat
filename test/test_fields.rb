require File.dirname(__FILE__) + "/test_helper"

class TestFields < BureaucratTestCase
  describe 'Field' do
    describe 'with empty options' do
      setup do
        @field = Fields::Field.new
      end

      should 'be required' do
        blank_value = ''
        assert_raise Utils::ValidationError do
          @field.clean(blank_value)
        end
      end
    end

    describe 'with required as false' do
      setup do
        @field = Fields::Field.new(:required => false)
      end

      should 'not be required' do
        blank_value = ''
        assert_nothing_raised do
          @field.clean(blank_value)
        end
      end
    end

    describe 'on clean' do
      setup do
        @field = Fields::Field.new
      end

      should 'return the original value if valid' do
        value = 'test'
        assert_equal(value, @field.clean(value))
      end
    end

    describe 'when copied' do
      setup do
        @field = Fields::Field.new(:initial => 'initial',
                                   :label => 'label')
        @field_copy = @field.dup
      end

      should 'have its own copy of initial value' do
        assert_not_equal(@field.initial.object_id, @field_copy.initial.object_id)
      end

      should 'have its own copy of the label' do
        assert_not_equal(@field.label.object_id, @field_copy.label.object_id)
      end

      should 'have its own copy of the error messaes' do
        assert_not_equal(@field.error_messages.object_id, @field_copy.error_messages.object_id)
      end
    end
  end

  describe 'CharField' do
    describe 'with empty options' do
      setup do
        @field = Fields::CharField.new
      end

      should 'not validate max length' do
        assert_nothing_raised do
          @field.clean("string" * 1000)
        end
      end

      should 'not validate min length' do
        assert_nothing_raised do
          @field.clean("1")
        end
      end
    end

    describe 'with max length of 10' do
      setup do
        @field = Fields::CharField.new(:max_length => 10)
      end

      should 'allow values with length <= 10' do
        assert_nothing_raised do
          @field.clean('a' * 10)
        end
      end

      should 'not allow values with length <= 10' do
        assert_raise Utils::ValidationError do
          @field.clean('a' * 11)
        end
      end
    end

    describe 'with min length of 10' do
      setup do
        @field = Fields::CharField.new(:min_length => 10)
      end

      should 'allow values with length >= 10' do
        assert_nothing_raised do
          @field.clean('a' * 10)
        end
      end

      should 'not allow values with length < 10' do
        assert_raise Utils::ValidationError do
          @field.clean('a' * 9)
        end
      end
    end

    describe 'on clean' do
      setup do
        @field = Fields::CharField.new
      end

      should 'return the original value if valid' do
        valid_value = 'test'
        assert_equal(valid_value, @field.clean(valid_value))
      end

      should 'return a blank string if value is nil and required is false' do
        @field.required = false
        nil_value = nil
        assert_equal('', @field.clean(nil_value))
      end

      should 'return a blank string if value is empty and required is false' do
        @field.required = false
        empty_value = ''
        assert_equal('', @field.clean(empty_value))
      end
    end

  end
end
