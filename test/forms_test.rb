require File.dirname(__FILE__) + "/test_helper"

class TestForm < BureaucratTestCase
  describe 'inherited form with a CharField' do
    class OneForm < Forms::Form
      include Bureaucrat::Fields

      field :name, CharField.new
    end

    should 'return an instance of Media when calling #media' do
      form = OneForm.new
      assert_kind_of(Widgets::Media, form.media)
    end

    should 'have a BoundField in [:name]' do
      form = OneForm.new
      assert_kind_of(Forms::BoundField, form[:name])
    end

    should 'be bound when data is provided' do
      form = OneForm.new(:name => 'name')
      assert_equal(true, form.bound?)
    end

    describe 'when calling #valid?' do
      should 'return false when data isn\'t valid' do
        form = OneForm.new(:name => nil)
        assert_equal(false, form.valid?)
      end

      should 'return true when data is valid' do
        form = OneForm.new(:name => 'valid')
        assert_equal(true, form.valid?)
      end
    end

    describe 'when calling #errors' do
      should 'have errors when invalid' do
        form = OneForm.new(:name => nil)
        assert_operator(form.errors.size, :>, 0)
      end

      should 'not have errors when valid' do
        form = OneForm.new(:name => 'valid')
        assert_equal(form.errors.size, 0)
      end
    end

    describe 'when calling #changed_data' do
      should 'return an empty list if no field was changed' do
        form = OneForm.new
        assert_equal([], form.changed_data)
      end

      should 'return a list of changed fields when modified' do
        form = OneForm.new(:name => 'changed')
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
        raise FieldValidationError.new("Invalid name") unless value == 'valid_name'
        value.upcase
      end
    end

    should 'not be valid if clean method fails' do
      form = CustomCleanForm.new(:name => 'other')
      assert_equal(false, form.valid?)
    end

    should 'be valid if clean method passes' do
      form = CustomCleanForm.new(:name => 'valid_name')
      assert_equal(true, form.valid?)
    end

    should 'set the value to the one returned by the custom clean method' do
      form = CustomCleanForm.new(:name => 'valid_name')
      form.valid?
      assert_equal('VALID_NAME', form.cleaned_data[:name])
    end

  end

  describe 'inherited form with two charfields when rendered' do
    class TwoForm < Forms::Form
      include Bureaucrat::Fields

      field :name, CharField.new(:label => 'Name')
      field :color, CharField.new
    end

    def setup
      @form = TwoForm.new(:name => 'name')
      @unbound_form = TwoForm.new
    end

    should 'should correctly render as table' do
      expected = normalize_html("<tr><th><label for='id_name'>Name:</label></th><td><input name='name' id='id_name' type='text' value='name'/></td></tr>\n<tr><th><label for='id_color'>Color:</label></th><td><ul class='errorlist'><li>This field is required</li></ul><input name='color' id='id_color' type='text'/></td></tr>")
      rendered = normalize_html(@form.as_table)
      assert_equal(expected, rendered)
    end

    should 'should correctly render as ul' do
      expected = normalize_html("<li><label for='id_name'>Name:</label> <input name='name' id='id_name' type='text' value='name'/></li>\n<li><ul class='errorlist'><li>This field is required</li></ul><label for='id_color'>Color:</label> <input name='color' id='id_color' type='text'/></li>")
      rendered = normalize_html(@form.as_ul)
      assert_equal(expected, rendered)
    end

    should 'should correctly render as p' do
      expected = normalize_html("<p><label for='id_name'>Name:</label> <input name='name' id='id_name' type='text' value='name'/></p>\nThis field is required\n<p><label for='id_color'>Color:</label> <input name='color' id='id_color' type='text'/></p>")
      rendered = normalize_html(@form.as_p)
      assert_equal(expected, rendered)
    end

    should 'correctly render as p when not bound' do
      expected = normalize_html("<p><label for='id_name'>Name:</label> <input name='name' id='id_name' type='text'/></p>\n<p><label for='id_color'>Color:</label> <input name='color' id='id_color' type='text'/></p>")
      rendered = normalize_html(@unbound_form.as_p)
      assert_equal(expected, rendered)
    end
  end

  describe 'populating objects' do
    class PopulatorForm < Forms::Form
      include Bureaucrat::Fields

      field :name, CharField.new(:required => false)
      field :color, CharField.new(:required => false)
      field :number, IntegerField.new(:required => false)
    end

    should 'correctly populate an object with all fields' do
      obj = Struct.new(:name, :color, :number).new
      name_value = 'The Name'
      color_value = 'Black'
      number_value = 10

      form = PopulatorForm.new(:name => name_value,
                               :color => color_value,
                               :number => number_value.to_s)

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

      form = PopulatorForm.new(:name => name_value,
                               :color => color_value,
                               :number => number_value.to_s)

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
