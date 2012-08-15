require_relative '../test_helper'
require 'bureaucrat/widgets/date_input'

module Widget
  class Test_on_clean < BureaucratTestCase
    def test_correctly_render
      input = Bureaucrat::Widgets::DateInput.new(nil, ['%Y/%m/%d'])
      expected = normalize_html("<input name='test' type='text' value='1982/10/25' />")
      rendered = normalize_html(input.render('test', Date.parse('1982-10-25')))
      assert_equal(expected, rendered)
    end

    def test_correctly_render_string
      input = Bureaucrat::Widgets::DateInput.new(nil, ['%Y/%m/%d'])
      expected = normalize_html("<input name='test' type='text' value='1982/10/25' />")
      rendered = normalize_html(input.render('test', '1982-10-25'))
      assert_equal(expected, rendered)
    end

    def test_correctly_render_string
      input = Bureaucrat::Widgets::DateInput.new(nil, ['%Y/%m/%d'])
      expected = normalize_html("<input name='test' type='text' value='1982-1' />")
      rendered = normalize_html(input.render('test', '1982-1'))
      assert_equal(expected, rendered)
    end

    def test_converts_to_date_with_the_first_format
      input = Bureaucrat::Widgets::DateInput.new(nil, ['%Y/%m/%d'])
      value = input.value_from_formdata({date: "1982/11/1"}, :date)
      assert_equal(Date.parse("1982/11/1"), value)
    end

    def test_handles_already_parsed_date
      input = Bureaucrat::Widgets::DateInput.new(nil, ['%Y/%m/%d'])
      value = input.value_from_formdata({date: Date.today}, :date)
      assert_equal(Date.today, value)
    end

    def test_converts_to_date_with_the_second_format
      input = Bureaucrat::Widgets::DateInput.new(nil, ['%Y/%m/%d', '%Y-%m-%d'])
      value = input.value_from_formdata({date: "1982-11-1"}, :date)
      assert_equal(Date.parse("1982-11-1"), value)
    end

    def test_does_not_convert_if_not_a_matching_format
      input = Bureaucrat::Widgets::DateInput.new(nil, ['%Y/%m/%d'])
      str_value = '1982-11-1'
      value = input.value_from_formdata({date: str_value}, :date)
      assert_equal(str_value, value)
    end
  end
end
