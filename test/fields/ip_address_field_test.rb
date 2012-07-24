require_relative '../test_helper'

module IPAddressFieldTests
  class Test_translation_errors < BureaucratTestCase
    def setup
      @field = Fields::IPAddressField.new({})
    end

    def test_translates_invalid_default
      assert_equal(I18n.t('bureaucrat.default_errors.fields.ip_address.invalid'), @field.error_messages[:invalid])
    end

    def test_translates_invalid_default
      assert_equal(I18n.t('bureaucrat.default_errors.fields.ip_address.invalid'), @field.error_messages[:invalid])
    end
  end
end
