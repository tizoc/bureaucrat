Bureaucrat
==========

Form handling for Ruby inspired by Django forms.

Structure
---------

                     Form ----> as_<render_mode>, valid?, errors/cleaned_data
                ______|________
              /       |         \
          Field     Field      Field  ----> clean
            |         |          |
          Widget    Widget     Widget ----> render

- A Form has a list of Fields.
- A Field has a Widget.
- A Widget knows how to render itself.
- A Field knows how to validate an input value and convert it from a string to the required type.
- A Form knows how to render all its fields along with all the required error messages.
- After validation, a valid Form responds to 'cleaned_data' by returning a hash of validated values.
- After validation an invalid Form responds to 'errors' by returning a hash of field_name => error_messages

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

    def quicker_form
      f = Class.new(Bureaucrat::Forms::Form)
      f.extend(Bureaucrat::Quickfields)
      yield f
      f
    end

    MyFormQuicker = quicker_form do |f|
      f.string  :nickname, :max_length => 50
      f.string  :realname, :required => false
      f.email   :email
      f.integer :age, :min_value => 0
      f.boolean :newsletter, :required => false
    end