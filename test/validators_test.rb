require_relative 'test_helper'

module TestValidators
  class Test_ValidateEmail < BureaucratTestCase
    def test_translated_message
      Bureaucrat::Validators::ValidateEmail.call(nil)
    rescue ValidationError => e
      assert_equal([I18n.t('bureaucrat.default_errors.validators.validate_email')], e.messages)
    end
  end

  class Test_ValidateSlug < BureaucratTestCase
    def test_translated_message
      Bureaucrat::Validators::ValidateSlug.call(nil)
    rescue ValidationError => e
      assert_equal([I18n.t('bureaucrat.default_errors.validators.validate_slug')], e.messages)
    end
  end

  class Test_ValidateIPV4Address < BureaucratTestCase
    def test_translated_message
      Bureaucrat::Validators::ValidateIPV4Address.call(nil)
    rescue ValidationError => e
      assert_equal([I18n.t('bureaucrat.default_errors.validators.validate_ipv4_address')], e.messages)
    end
  end

  class Test_ValidateCommaSeparatedIntegerList < BureaucratTestCase
    def test_translated_message
      Bureaucrat::Validators::ValidateCommaSeparatedIntegerList.call(nil)
    rescue ValidationError => e
      assert_equal([I18n.t('bureaucrat.default_errors.validators.validate_comma_separated_integer_list')], e.messages)
    end
  end

  class Test_MaxValueValidator < BureaucratTestCase
    def test_translated_message
      Bureaucrat::Validators::MaxValueValidator.new(20).call(21)
    rescue ValidationError => e
      assert_equal(['Ensure this value is less than or equal to 20.'], e.messages)
    end
  end

  class Test_MinValueValidator < BureaucratTestCase
    def test_translated_message
      Bureaucrat::Validators::MinValueValidator.new(50).call(19)
    rescue ValidationError => e
      assert_equal(['Ensure this value is greater than or equal to 50.'], e.messages)
    end
  end

  class Test_MaxLengthValidator < BureaucratTestCase
    def test_translated_message
      Bureaucrat::Validators::MaxLengthValidator.new(5).call('123456')
    rescue ValidationError => e
      assert_equal(['Ensure this value has at most 5 characters (it has 6).'], e.messages)
    end
  end

  class Test_MinLengthValidator < BureaucratTestCase
    def test_translated_message
      Bureaucrat::Validators::MinLengthValidator.new(3).call('12')
    rescue ValidationError => e
      assert_equal(['Ensure this value has at least 3 characters (it has 2).'], e.messages)
    end
  end

  class Test_BaseValidator < BureaucratTestCase
    def test_translated_message
      Bureaucrat::Validators::BaseValidator.new('18').call('john')
    rescue ValidationError => e
      assert_equal(['Ensure this value is 18 (it is john).'], e.messages)
    end
  end
end
