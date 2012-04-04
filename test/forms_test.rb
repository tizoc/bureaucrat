require_relative 'test_helper'

class TestForm < BureaucratTestCase
  describe 'inherited form with a CharField' do
    class OneForm < Forms::Form
      include Bureaucrat::Fields

      field :name, CharField.new
    end

    should 'have a BoundField in [:name]' do
      form = OneForm.new
      assert_kind_of(Forms::BoundField, form[:name])
    end

    should 'be bound when data is provided' do
      form = OneForm.new(name: 'name')
      assert_equal(true, form.bound?)
    end

    describe 'when calling #valid?' do
      should 'return false when data isn\'t valid' do
        form = OneForm.new(name: nil)
        assert_equal(false, form.valid?)
      end

      should 'return true when data is valid' do
        form = OneForm.new(name: 'valid')
        assert_equal(true, form.valid?)
      end
    end

    describe 'when calling #errors' do
      should 'have errors when invalid' do
        form = OneForm.new(name: nil)
        assert_operator(form.errors.size, :>, 0)
      end

      should 'not have errors when valid' do
        form = OneForm.new(name: 'valid')
        assert_equal(form.errors.size, 0)
      end
    end

    describe 'when calling #changed_data' do
      should 'return an empty list if no field was changed' do
        form = OneForm.new
        assert_equal([], form.changed_data)
      end

      should 'return a list of changed fields when modified' do
        form = OneForm.new(name: 'changed')
        assert_equal([:name], form.changed_data)
      end
    end
  end

  describe 'form with custom clean proc on field' do
    class CustomCleanForm < Forms::Form
      include Bureaucrat::Fields

      field :name, CharField.new

      def clean_name
        value = cleaned_data[:name]
        unless value == 'valid_name'
          raise Bureaucrat::ValidationError.new("Invalid name")
        end
        value.upcase
      end
    end

    should 'not be valid if clean method fails' do
      form = CustomCleanForm.new(name: 'other')
      assert_equal(false, form.valid?)
    end

    should 'be valid if clean method passes' do
      form = CustomCleanForm.new(name: 'valid_name')
      assert_equal(true, form.valid?)
    end

    should 'set the value to the one returned by the custom clean method' do
      form = CustomCleanForm.new(name: 'valid_name')
      form.valid?
      assert_equal('VALID_NAME', form.cleaned_data[:name])
    end

  end

  describe 'populating objects' do
    class PopulatorForm < Forms::Form
      include Bureaucrat::Fields

      field :name, CharField.new(required: false)
      field :color, CharField.new(required: false)
      field :number, IntegerField.new(required: false)
    end

    should 'correctly populate an object with all fields' do
      obj = Struct.new(:name, :color, :number).new
      name_value = 'The Name'
      color_value = 'Black'
      number_value = 10

      form = PopulatorForm.new(name: name_value,
                               color: color_value,
                               number: number_value.to_s)

      assert form.valid?

      form.populate_object(obj)

      assert_equal(name_value, obj.name)
      assert_equal(color_value, obj.color)
      assert_equal(number_value, obj.number)
    end

    should 'correctly populate an object without all fields' do
      obj = Struct.new(:name, :number).new
      name_value = 'The Name'
      color_value = 'Black'
      number_value = 10

      form = PopulatorForm.new(name: name_value,
                               color: color_value,
                               number: number_value.to_s)

      assert form.valid?

      form.populate_object(obj)

      assert_equal(name_value, obj.name)
      assert_equal(number_value, obj.number)
    end

    should 'correctly populate an object with all fields with some missing values' do
      obj = Struct.new(:name, :color, :number).new('a', 'b', 2)

      form = PopulatorForm.new({})

      assert form.valid?

      form.populate_object(obj)

      assert_equal('', obj.name)
      assert_equal('', obj.color)
      assert_equal(nil, obj.number)
    end
  end
end
