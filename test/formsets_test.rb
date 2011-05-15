require File.dirname(__FILE__) + "/test_helper"

class SimpleForm < Bureaucrat::Forms::Form
  include Bureaucrat::Fields

  field :name, CharField.new
end

SimpleFormFormSet =
  Bureaucrat::Formsets.make_formset_class(SimpleForm, :extra => 2)

class CustomFormSet < Bureaucrat::Formsets::BaseFormSet
  def clean
    raise Bureaucrat::ValidationError.new('This is wrong!')
  end
end

SimpleFormCustomFormSet =
  Bureaucrat::Formsets.make_formset_class(SimpleForm,
                                          :extra => 2,
                                          :formset => CustomFormSet)

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

  describe "Formset with clean method raising a ValidationError exception" do
    setup do
      management_form_data = {
        :'form-TOTAL_FORMS' => '2',
        :'form-INITIAL_FORMS' => '2'
      }
      valid_data = {:'form-0-name' => 'Lynch', :'form-1-name' => 'Tio'}
      @bound_set =
        SimpleFormCustomFormSet.new(management_form_data.merge(valid_data))
    end

    should 'not be valid' do
      assert_equal(false, @bound_set.valid?)
    end

    should 'add clean errors to nonfield errors' do
      @bound_set.valid?
      assert_equal(["This is wrong!"],  @bound_set.non_form_errors)
    end
  end
end
