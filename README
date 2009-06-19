Bureaucrat
==========

Form handling for Ruby inspired by Django forms.

Usage
-----

require 'lib/bureaucrat'

class MyForm < Bureaucrat::Forms::Form
  include Bureaucrat::Fields

  field :nickname, CharField.new(:max_length => 50)
  field :realname, CharField.new(:required => false)
  field :email, EmailField.new
  field :age, IntegerField.new(:min_value => 0)
  field :newsletter, BooleanField.new(:required => false) 
end

unbound_form = MyForm.new
unbound_form.valid? # => false
unbound_form.errors # => {}
unbound_form.cleaned_data # => nil
puts unbound_form.as_p
# Prints:
# <p> <input type="text" name="nickname" id="id_nickname" /></p>
# <p> <input type="text" name="realname" id="id_realname" /></p>
# <p> <input type="text" name="email" id="id_email" /></p>
# <p> <input type="text" name="age" id="id_age" /></p>
# <p> <input type="checkbox" name="newsletter" id="id_newsletter" /></p>


invalid_bound_form = MyForm.new(:nickname => 'bureaucrat', :email => 'badformat', :age => '30')
invalid_bound_form.valid? # => false
invalid_bound_form.errors # {:email => ["Enter a valid e-mail address."]}
invalid_bound_form.cleaned_data # => nil
puts invalid_bound_form.as_table
# Prints:
# <tr><th></th><td><input type="text" value="bureaucrat" name="nickname" id="id_nickname" /></td></tr>
# <tr><th></th><td><input type="text" name="realname" id="id_realname" /></td></tr>
# <tr><th></th><td><ul class="errorlist"><li>Enter a valid e-mail address.</li></ul><input type="text" value="badformat" name="email" id="id_email" /></td></tr>
# <tr><th></th><td><input type="text" value="30" name="age" id="id_age" /></td></tr>
# <tr><th></th><td><input type="checkbox" name="newsletter" id="id_newsletter" /></td></tr>

valid_bound_form = MyForm.new(:nickname => 'bureaucrat', :email => 'valid@email.com', :age => '30')
valid_bound_form.valid? # => false
valid_bound_form.errors # {}
valid_bound_form.cleaned_data # => {:age => 30, :newsletter => false, :nickname => "bureaucrat", :realname => "", :email = >"valid@email.com"}
puts valid_bound_form.as_ul
# Prints:
# <li> <input type="text" value="bureaucrat" name="nickname" id="id_nickname" /></li>
# <li> <input type="text" name="realname" id="id_realname" /></li>
# <li> <input type="text" value="valid@email.com" name="email" id="id_email" /></li>
# <li> <input type="text" value="30" name="age" id="id_age" /></li>
# <li> <input type="checkbox" name="newsletter" id="id_newsletter" /></li>
