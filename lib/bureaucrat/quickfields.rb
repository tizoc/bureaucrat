require 'bureaucrat/fields'

module Bureaucrat
module Quickfields
  include Fields

  def label_for(name, text)
    base_fields[name].label = text
  end

  def autolabel(*names)
    if names.length > 0
      names.each do |name|
          base_fields[name].label ||= name.to_s.gsub(/_/, ' ').capitalize if
            base_fields[name]
        end
    else
      autolabel(*base_fields.keys)
    end
  end

  def string(name, options={})
    field name, CharField.new(options)
  end

  def password(name, options={})
    field name, CharField.new(options.merge(:widget => Widgets::PasswordInput.new))
  end

  def integer(name, options={})
    field name, IntegerField.new(options)
  end

  def decimal(name, options={})
    field name, BigDecimalField.new(options)
  end

  def regex(name, regexp, options={})
    field name, RegexField.new(regexp, options)
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
