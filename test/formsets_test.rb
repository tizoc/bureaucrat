require File.dirname(__FILE__) + "/test_helper"

class SimpleForm < Bureaucrat::Forms::Form
  include Bureaucrat::Fields

  field :name, CharField.new
end

SimpleFormFormSet = Bureaucrat::Formsets.make_formset_class(SimpleForm,
                                                            :extra => 2)

class TestFormset < BureaucratTestCase
  describe 'formset with empty data' do
    setup do
      management_form_data = {
        :'form-TOTAL_FORMS' => '2',
        :'form-INITIAL_FORMS' => '2'
      }
      valid_data = {:'form-0-name' => 'Lynch', :'form-1-name' => 'Tio'}
      invalid_data = {:'form-0-name' => 'Lynch', :'form-1-name' => ''}
      @set = SimpleFormFormSet.new
      @valid_bound_set = SimpleFormFormSet.new(management_form_data.merge(valid_data))
      @invalid_bound_set = SimpleFormFormSet.new(management_form_data.merge(invalid_data))
    end

    should 'correctly render when calling as_table' do
      expected = normalize_html("<input name='form-TOTAL_FORMS' id='id_form-TOTAL_FORMS' type='hidden' value='2'/><input name='form-INITIAL_FORMS' id='id_form-INITIAL_FORMS' type='hidden' value='0'/>\n<tr><th><label for='id_form-0-name'>Name:</label></th><td><input name='form-0-name' id='id_form-0-name' type='text'/></td></tr> <tr><th><label for='id_form-1-name'>Name:</label></th><td><input name='form-1-name' id='id_form-1-name' type='text'/></td></tr>")
      rendered = normalize_html(@set.as_table)
      p @set.management_form.to_s
      assert_equal(expected, rendered)
    end

    should '#valid? returns true if all forms are valid' do
      assert(@valid_bound_set.valid?)
    end

    should '#valid? returns false if there is an invalid form' do
      assert(!@invalid_bound_set.valid?)
    end

    should 'correctly return the list of errors' do
      assert_equal([{}, {:name => ["This field is required"]}],
                   @invalid_bound_set.errors)
    end

    should 'correctly return the list of cleaned data' do
      expected = [{:name => 'Lynch'}, {:name => 'Tio'}]
      result = @valid_bound_set.cleaned_data
      assert_equal(expected, result)
    end
  end
end
