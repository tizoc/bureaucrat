module Bureaucrat
  # Shortcuts for declaring form fields
  module Quickfields
    include Fields

    # Hide field named +name+
    def hide(name)
      base_fields[name] = base_fields[name].dup
      base_fields[name].widget = Widgets::HiddenInput.new
    end

    # Delete field named +name+
    def delete(name)
      base_fields.delete name
    end

    # Declare a +CharField+ with text input widget
    def string(name, options = {})
      field name, CharField.new(options)
    end

    # Declare a +CharField+ with text area widget
    def text(name, options = {})
      field name, CharField.new(options.merge(:widget => Widgets::Textarea.new))
    end

    # Declare a +CharField+ with password widget
    def password(name, options = {})
      field name, CharField.new(options.merge(:widget => Widgets::PasswordInput.new))
    end

    # Declare an +IntegerField+
    def integer(name, options = {})
      field name, IntegerField.new(options)
    end

    # Declare a +BigDecimalField+
    def decimal(name, options = {})
      field name, BigDecimalField.new(options)
    end

    # Declare a +RegexField+
    def regex(name, regexp, options = {})
      field name, RegexField.new(regexp, options)
    end

    # Declare an +EmailField+
    def email(name, options = {})
      field name, EmailField.new(options)
    end

    # Declare a +FileField+
    def file(name, options = {})
      field name, FileField.new(options)
    end

    # Declare a +BooleanField+
    def boolean(name, options = {})
      field name, BooleanField.new(options)
    end

    # Declare a +NullBooleanField+
    def null_boolean(name, options = {})
      field name, NullBooleanField.new(options)
    end

    # Declare a +ChoiceField+ with +choices+
    def choice(name, choices = [], options = {})
      field name, ChoiceField.new(choices, options)
    end

    # Declare a +TypedChoiceField+ with +choices+
    def typed_choice(name, choices = [], options = {})
      field name, TypedChoiceField.new(choices, options)
    end

    # Declare a +MultipleChoiceField+ with +choices+
    def multiple_choice(name, choices = [], options = {})
      field name, MultipleChoiceField.new(choices, options)
    end

    # Declare a +ChoiceField+ using the +RadioSelect+ widget
    def radio_choice(name, choices = [], options = {})
      field name, ChoiceField.new(choices, options.merge(:widget => Widgets::RadioSelect.new))
    end

    # Declare a +MultipleChoiceField+ with the +CheckboxSelectMultiple+ widget
    def checkbox_multiple_choice(name, choices = [], options = {})
      field name, MultipleChoiceField.new(choices, options.merge(:widget => Widgets::CheckboxSelectMultiple.new))
    end
  end
end
