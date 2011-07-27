Bureaucrat
==========

Form handling for Ruby inspired by [Django forms](https://docs.djangoproject.com/en/dev/#forms).

Description
-----------

Bureaucrat is a library for handling the processing, validation and rendering of HTML forms.

Structure of a Form
-------------------

                     Form ----> valid?, errors/cleaned_data
                ______|________
              /       |         \
          Field     Field      Field  ----> clean
            |         |          |
          Widget    Widget     Widget ----> render

**Form**:
Collection of named Fields, handles global validation and the last pass of
data conversion.
After validation, a valid Form responds to `cleaned_data` by returning a
hash of validated values and an invalid Form responds to `errors` by
returning a hash of field_name => error_messages.

**Field**:
Handles the validation and data conversion of each field belonging to the Form. Each Field is associated to a name on the parent Form.

**Widget**:
Handles the rendering of a Form field. Each Field has two widgets associated, one for normal rendering, and another for hidden inputs rendering. Every type of Field has default Widgets defined, but they can be overriden on a per-Form basis.

Usage examples
--------------

    require 'bureaucrat'
    require 'bureaucrat/quickfields'

    class MyForm < Bureaucrat::Forms::Form
      extend Bureaucrat::Quickfields

      string  :nickname, :max_length => 50
      string  :realname, :require => false
      email   :email
      integer :age, :min_value => 0
      boolean :newsletter, :required => false

      # Note: Bureaucrat doesn't define save
      def save
        user = User.create!(cleaned_data)
        Mailer.deliver_confirmation_mail(user)
        user
      end
    end

    # A Form initialized without parameters is an unbound Form.
    unbound_form = MyForm.new
    unbound_form.valid? # => false
    unbound_form.errors # => {}
    unbound_form.cleaned_data # => nil
    puts unbound_form.as_p
    # Prints:
    # <p><label for="id_nickname">Nickname:</label> <input type="text" name="nickname" id="id_nickname" maxlength="50" /></p>
    # <p><label for="id_realname">Realname:</label> <input type="text" name="realname" id="id_realname" /></p>
    # <p><label for="id_email">Email:</label> <input type="text" name="email" id="id_email" /></p>
    # <p><label for="id_age">Age:</label> <input type="text" name="age" id="id_age" /></p>
    # <p><label for="id_newsletter">Newsletter:</label> <input type="checkbox" name="newsletter" id="id_newsletter" /></p>

    invalid_bound_form = MyForm.new(:nickname => 'bureaucrat', :email => 'badformat', :age => '30')
    invalid_bound_form.valid? # => false
    invalid_bound_form.errors # {:email => ["Enter a valid e-mail address."]}
    invalid_bound_form.cleaned_data # => nil
    puts invalid_bound_form.as_table
    # Prints:
    # <tr><th><label for="id_nickname">Nickname:</label></th><td><input type="text" value="bureaucrat" name="nickname" id="id_nickname" maxlength="50" /></td></tr>
    # <tr><th><label for="id_realname">Realname:</label></th><td><ul class="errorlist"><li>This field is required</li></ul><input type="text" name="realname" id="id_realname" /></td></tr>
    # <tr><th><label for="id_email">Email:</label></th><td><ul class="errorlist"><li>Enter a valid e-mail address.</li></ul><input type="text" value="badformat" name="email" id="id_email" /></td></tr>
    # <tr><th><label for="id_age">Age:</label></th><td><input type="text" value="30" name="age" id="id_age" /></td></tr>
    # <tr><th><label for="id_newsletter">Newsletter:</label></th><td><input type="checkbox" name="newsletter" id="id_newsletter" /></td></tr>

    valid_bound_form = MyForm.new(:nickname => 'bureaucrat', :email => 'valid@email.com', :age => '30')
    valid_bound_form.valid? # => true
    valid_bound_form.errors # {}
    valid_bound_form.cleaned_data # => {:age => 30, :newsletter => false, :nickname => "bureaucrat", :realname => "", :email = >"valid@email.com"}
    puts valid_bound_form.as_ul
    # Prints:
    # <li><label for="id_nickname">Nickname:</label> <input type="text" value="bureaucrat" name="nickname" id="id_nickname" maxlength="50" /></li>
    # <li><ul class="errorlist"><li>This field is required</li></ul><label for="id_realname">Realname:</label> <input type="text" name="realname" id="id_realname" /></li>
    # <li><label for="id_email">Email:</label> <input type="text" value="valid@email.com" name="email" id="id_email" /></li>
    # <li><label for="id_age">Age:</label> <input type="text" value="30" name="age" id="id_age" /></li>
    # <li><label for="id_newsletter">Newsletter:</label> <input type="checkbox" name="newsletter" id="id_newsletter" /></li>

    valid_bound_form.save # A new User is created and a confirmation mail is delivered

Examples of different ways of defining forms
--------------

    require 'bureaucrat'
    require 'bureaucrat/quickfields'

    class MyForm < Bureaucrat::Forms::Form
      include Bureaucrat::Fields

      field :nickname, CharField.new(:max_length => 50)
      field :realname, CharField.new(:required => false)
      field :email, EmailField.new
      field :age, IntegerField.new(:min_value => 0)
      field :newsletter, BooleanField.new(:required => false) 
    end

    class MyFormQuick < Bureaucrat::Forms::Form
      extend Bureaucrat::Quickfields

      string  :nickname, :max_length => 50
      string  :realname, :required => false
      email   :email
      integer :age, :min_value => 0
      boolean :newsletter, :required => false
    end

    def inline_form
      f = Class.new(Bureaucrat::Forms::Form)
      f.extend(Bureaucrat::Quickfields)
      yield f
      f
    end

    form_maker = inline_form do |f|
      f.string  :nickname, :max_length => 50
      f.string  :realname, :required => false
      f.email   :email
      f.integer :age, :min_value => 0
      f.boolean :newsletter, :required => false
    end