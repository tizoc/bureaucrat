require_relative 'test_helper'

class TestFields < BureaucratTestCase
  describe 'Field' do
    describe 'with empty options' do
      setup do
        @field = Fields::Field.new
      end

      should 'be required' do
        blank_value = ''
        assert_raises(ValidationError) do
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

      should 'not allow values with length > 10' do
        assert_raises(ValidationError) do
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
        assert_raises(ValidationError) do
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

  describe 'IntegerField' do
    describe 'with max value of 10' do
      setup do
        @field = Fields::IntegerField.new(:max_value => 10)
      end

      should 'allow values <= 10' do
        assert_nothing_raised do
          @field.clean('10')
        end
      end

      should 'not allow values > 10' do
        assert_raises(ValidationError) do
          @field.clean('11')
        end
      end
    end

    describe 'with min value of 10' do
      setup do
        @field = Fields::IntegerField.new(:min_value => 10)
      end

      should 'allow values >= 10' do
        assert_nothing_raised do
          @field.clean('10')
        end
      end

      should 'not allow values < 10' do
        assert_raises(ValidationError) do
          @field.clean('9')
        end
      end

    end

    describe 'on clean' do
      setup do
        @field = Fields::IntegerField.new
      end

      should 'return an integer if valid' do
        valid_value = '123'
        assert_equal(123, @field.clean(valid_value))
      end

      should 'return nil if value is nil and required is false' do
        @field.required = false
        assert_nil(@field.clean(nil))
      end

      should 'return nil if value is empty and required is false' do
        @field.required = false
        empty_value = ''
        assert_nil(@field.clean(empty_value))
      end

      should 'not validate invalid formats' do
        invalid_formats = ['a', 'hello', '23eeee', '.', 'hi323',
                           'joe@example.com', '___3232___323',
                           '123.0', '123..4']

        invalid_formats.each do |invalid|
          assert_raises(ValidationError) do
            @field.clean(invalid)
          end
        end
      end

      should 'validate valid formats' do
        valid_formats = ['3', '100', '-100', '0', '-0']

        assert_nothing_raised do
          valid_formats.each do |valid|
            @field.clean(valid)
          end
        end
      end

      should 'return an instance of Integer if valid' do
        result = @field.clean('7')
        assert_kind_of(Integer, result)
      end
    end

  end

  describe 'FloatField' do
    describe 'with max value of 10.5' do
      setup do
        @field = Fields::FloatField.new(:max_value => 10.5)
      end

      should 'allow values <= 10.5' do
        assert_nothing_raised do
          @field.clean('10.5')
        end
      end

      should 'not allow values > 10.5' do
        assert_raises(ValidationError) do
          @field.clean('10.55')
        end
      end
    end

    describe 'with min value of 10.5' do
      setup do
        @field = Fields::FloatField.new(:min_value => 10.5)
      end

      should 'allow values >= 10.5' do
        assert_nothing_raised do
          @field.clean('10.5')
        end
      end

      should 'not allow values < 10.5' do
        assert_raises(ValidationError) do
          @field.clean('10.49')
        end
      end
    end

    describe 'on clean' do
      setup do
        @field = Fields::FloatField.new
      end

      should 'return nil if value is nil and required is false' do
        @field.required = false
        assert_nil(@field.clean(nil))
      end

      should 'return nil if value is empty and required is false' do
        @field.required = false
        empty_value = ''
        assert_nil(@field.clean(empty_value))
      end

      should 'not validate invalid formats' do
        invalid_formats = ['a', 'hello', '23eeee', '.', 'hi323',
                           'joe@example.com', '___3232___323',
                           '123..', '123..4']

        invalid_formats.each do |invalid|
          assert_raises(ValidationError) do
            @field.clean(invalid)
          end
        end
      end

      should 'validate valid formats' do
        valid_formats = ['3.14', "100", "1233.", ".3333", "0.434", "0.0"]

        assert_nothing_raised do
          valid_formats.each do |valid|
            @field.clean(valid)
          end
        end
      end

      should 'return an instance of Float if valid' do
        result = @field.clean('3.14')
        assert_instance_of(Float, result)
      end
    end
  end

  describe 'BigDecimalField' do
    describe 'with max value of 10.5' do
      setup do
        @field = Fields::BigDecimalField.new(:max_value => 10.5)
      end

      should 'allow values <= 10.5' do
        assert_nothing_raised do
          @field.clean('10.5')
        end
      end

      should 'not allow values > 10.5' do
        assert_raises(ValidationError) do
          @field.clean('10.55')
        end
      end
    end

    describe 'with min value of 10.5' do
      setup do
        @field = Fields::BigDecimalField.new(:min_value => 10.5)
      end

      should 'allow values >= 10.5' do
        assert_nothing_raised do
          @field.clean('10.5')
        end
      end

      should 'not allow values < 10.5' do
        assert_raises(ValidationError) do
          @field.clean('10.49')
        end
      end
    end

    describe 'on clean' do
      setup do
        @field = Fields::BigDecimalField.new
      end

      should 'return nil if value is nil and required is false' do
        @field.required = false
        assert_nil(@field.clean(nil))
      end

      should 'return nil if value is empty and required is false' do
        @field.required = false
        empty_value = ''
        assert_nil(@field.clean(empty_value))
      end

      should 'not validate invalid formats' do
        invalid_formats = ['a', 'hello', '23eeee', '.', 'hi323',
                           'joe@example.com', '___3232___323',
                           '123..', '123..4']

        invalid_formats.each do |invalid|
          assert_raises(ValidationError) do
            @field.clean(invalid)
          end
        end
      end

      should 'validate valid formats' do
        valid_formats = ['3.14', "100", "1233.", ".3333", "0.434", "0.0"]

        assert_nothing_raised do
          valid_formats.each do |valid|
            @field.clean(valid)
          end
        end
      end

      should 'return an instance of BigDecimal if valid' do
        result = @field.clean('3.14')
        assert_instance_of(BigDecimal, result)
      end
    end
  end

  describe 'RegexField' do
    setup do
      @field = Fields::RegexField.new(/ba(na){2,}/)
    end

    describe 'on clean' do
      should 'validate matching values' do
        valid_values = ['banana', 'bananananana']
        valid_values.each do |valid|
          assert_nothing_raised do
            @field.clean(valid)
          end
        end
      end

      should 'not validate non-matching values' do
        invalid_values = ['bana', 'spoon']
        assert_raises(ValidationError) do
          invalid_values.each do |invalid|
            @field.clean(invalid)
          end
        end
      end

      should 'return a blank string if value is empty and required is false' do
        @field.required = false
        empty_value = ''
        assert_equal('', @field.clean(empty_value))
      end
    end
  end

  describe 'EmailField' do
    setup do
      @field = Fields::EmailField.new
    end

    describe 'on clean' do
      should 'validate email-matching values' do
        valid_values = ['email@domain.com', 'email+extra@domain.com',
                        'email@domain.fm', 'email@domain.co.uk']
        valid_values.each do |valid|
          assert_nothing_raised do
            @field.clean(valid)
          end
        end
      end

      should 'not validate non-email-matching values' do
        invalid_values = ['banana', 'spoon', 'invalid@dom#ain.com',
                          'invalid@@domain.com', 'invalid@domain',
                          'invalid@.com']
        invalid_values.each do |invalid|
          assert_raises(ValidationError) do
            @field.clean(invalid)
          end
        end
      end
    end
  end

  describe 'BooleanField' do
    setup do
      @true_values = [1, true, 'true', '1']
      @false_values = [nil, 0, false, 'false', '0']
      @field = Fields::BooleanField.new
    end

    describe 'on clean' do
      should 'return true for true values' do
        @true_values.each do |true_value|
          assert_equal(true, @field.clean(true_value))
        end
      end

      should 'return false for false values' do
        @field.required = false
        @false_values.each do |false_value|
          assert_equal(false, @field.clean(false_value))
        end
      end

      should 'validate on true values when required' do
        assert_nothing_raised do
          @true_values.each do |true_value|
            @field.clean(true_value)
          end
        end
      end

      should 'not validate on false values when required' do
        @false_values.each do |false_value|
          assert_raises(ValidationError) do
            @field.clean(false_value)
          end
        end
      end

      should 'validate on false values when not required' do
        @field.required = false
        assert_nothing_raised do
          @false_values.each do |false_value|
            @field.clean(false_value)
          end
        end
      end
    end
  end

  describe 'NullBooleanField' do
    setup do
      @true_values = [true, 'true', '1']
      @false_values = [false, 'false', '0']
      @null_values = [nil, '', 'banana']
      @field = Fields::NullBooleanField.new
    end

    describe 'on clean' do
      should 'return true for true values' do
        @true_values.each do |true_value|
          assert_equal(true, @field.clean(true_value))
        end
      end

      should 'return false for false values' do
        @false_values.each do |false_value|
          assert_equal(false, @field.clean(false_value))
        end
      end

      should 'return nil for null values' do
        @null_values.each do |null_value|
          assert_equal(nil, @field.clean(null_value))
        end
      end

      should 'validate on all values' do
        all_values = @true_values + @false_values + @null_values
        assert_nothing_raised do
          all_values.each do |value|
            @field.clean(value)
          end
        end
      end
    end
  end

  describe 'ChoiceField' do
    setup do
      @choices = [['tea', 'Tea'], ['milk', 'Milk']]
      @choices_hash = [[{ :value => "able" }, "able"], [{ :value => "baker" }, "Baker"]]
      @field = Fields::ChoiceField.new(@choices)
      @field_hash = Fields::ChoiceField.new(@choices_hash)
    end

    describe 'on clean' do
      should 'validate all values in choices list' do
        assert_nothing_raised do
          @choices.collect(&:first).each do |valid|
            @field.clean(valid)
          end
        end
      end

      should 'validate all values in a hash choices list' do
        assert_nothing_raised do
          @choices_hash.collect(&:first).each do |valid|
            @field_hash.clean(valid[:value])
          end
        end
      end

      should 'not validate a value not in choices list' do
        assert_raises(ValidationError) do
          @field.clean('not_in_choices')
        end
      end

      should 'not validate a value not in a hash choices list' do
        assert_raises(ValidationError) do
          @field_hash.clean('not_in_choices')
        end
      end

      should 'return the original value if valid' do
        value = 'tea'
        result = @field.clean(value)
        assert_equal(value, result)
      end

      should 'return the original value if valid from a hash choices list' do
        value = 'baker'
        result = @field_hash.clean(value)
        assert_equal(value, result)
      end

      should 'return an empty string if value is empty and not required' do
        @field.required = false
        result = @field.clean('')
        assert_equal('', result)
      end

      should 'return an empty string if value is empty and not required from a hash choices list' do
        @field_hash.required = false
        result = @field_hash.clean('')
        assert_equal('', result)
      end
    end
  end

  describe 'TypedChoiceField' do
    setup do
      @choices = [[1, 'One'], [2, 'Two'], ['3', 'Three']]
      to_int = lambda{|val| Integer(val)}
      @field = Fields::TypedChoiceField.new(@choices,
                                            :coerce => to_int)
    end

    describe 'on clean' do
      should 'validate all values in choices list' do
        assert_nothing_raised do
          @choices.collect(&:first).each do |valid|
            @field.clean(valid)
          end
        end
      end

      should 'not validate a value not in choices list' do
        assert_raises(ValidationError) do
          @field.clean('four')
        end
      end

      should 'return the original value if valid' do
        value = 1
        result = @field.clean(value)
        assert_equal(value, result)
      end

      should 'return a coerced version of the original value if valid but of different type' do
        value = 2
        result = @field.clean(value.to_s)
        assert_equal(value, result)
      end

      should 'return an empty string if value is empty and not required' do
        @field.required = false
        result = @field.clean('')
        assert_equal('', result)
      end
    end
  end

  describe 'MultipleChoiceField' do
    setup do
      @choices = [['tea', 'Tea'], ['milk', 'Milk'], ['coffee', 'Coffee']]
      @field = Fields::MultipleChoiceField.new(@choices)
    end

    describe 'on clean' do
      should 'validate all single values in choices list' do
        assert_nothing_raised do
          @choices.collect(&:first).each do |valid|
            @field.clean([valid])
          end
        end
      end

      should 'validate multiple values' do
        values = ['tea', 'coffee']
        assert_nothing_raised do
          @field.clean(values)
        end
      end

      should 'not validate a value not in choices list' do
        assert_raises(ValidationError) do
          @field.clean(['tea', 'not_in_choices'])
        end
      end

      should 'return the original value if valid' do
        value = 'tea'
        result = @field.clean([value])
        assert_equal([value], result)
      end

      should 'return an empty list if value is empty and not required' do
        @field.required = false
        result = @field.clean([])
        assert_equal([], result)
      end
    end
  end

end
