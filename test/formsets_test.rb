require_relative 'test_helper'

module FormsetTests
  class SimpleForm < Bureaucrat::Forms::Form
    include Bureaucrat::Fields

    field :name, CharField.new
  end

  SimpleFormFormSet =
    Bureaucrat::Formsets.make_formset_class(SimpleForm, extra: 2)

  class CustomFormSet < Bureaucrat::Formsets::BaseFormSet
    def clean
      raise Bureaucrat::ValidationError.new('This is wrong!')
    end
  end

  SimpleFormCustomFormSet =
    Bureaucrat::Formsets.make_formset_class(SimpleForm,
                                            extra: 2,
                                            formset: CustomFormSet)

  class Test_formset_with_empty_data < BureaucratTestCase
    def setup
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

    def test_#valid?_returns_true_if_all_forms_are_valid
      assert(@valid_bound_set.valid?)
    end

    def test_#valid?_returns_false_if_there_is_an_invalid_form
      assert(!@invalid_bound_set.valid?)
    end

    def test_correctly_return_the_list_of_errors
      assert_equal([{}, {name: ["This field is required"]}],
                   @invalid_bound_set.errors)
    end

    def test_correctly_return_the_list_of_cleaned_data
      expected = [{'name' => 'Lynch'}, {'name' => 'Tio'}]
      result = @valid_bound_set.cleaned_data
      assert_equal(expected, result)
    end
  end

  class Test_Formset_with_clean_method_raising_a_ValidationError_exception < BureaucratTestCase
    def setup
      management_form_data = {
        :'form-TOTAL_FORMS' => '2',
        :'form-INITIAL_FORMS' => '2'
      }
      valid_data = {:'form-0-name' => 'Lynch', :'form-1-name' => 'Tio'}
      @bound_set =
        SimpleFormCustomFormSet.new(management_form_data.merge(valid_data))
    end

    def test_not_be_valid
      assert_equal(false, @bound_set.valid?)
    end

    def test_add_clean_errors_to_nonfield_errors
      @bound_set.valid?
      assert_equal(["This is wrong!"],  @bound_set.non_form_errors)
    end
  end
end
