require 'bureaucrat/fields'

module Bureaucrat
module Quickfields
  include Fields

  def string(name, options={})
    field name, CharField.new(options)
  end

  def integer(name, options={})
    field name, IntegerField.new(options)
  end

  def decimal(name, options={})
    field name, BigDecimalField.new(options)
  end

  def regex(name, options={})
    field name, RegexField.new(options)
  end

  def email(name, options={})
    field name, EmailField.new(options)
  end

  def file(name, options={})
    field name, FileField.new(options)
  end

  def boolean(name, options={})
    field name, BooleanField.new(options)
  end

  def null_boolean(name, options={})
    field name, NullBooleanField.new(options)
  end

  def choice(name, choices=[], options={})
    field name, ChoiceField.new(choices, options)
  end

  def typed_choice(name, choices=[], options={})
    field name, TypedChoiceField.new(choices, options)
  end

  def multiple_choice(name, choices=[], options={})
    field name, MultipleChoiceField.new(choices, options)
  end

end; end
