require_relative '../test_helper'
require 'bureaucrat/widgets/multi_date'

module Widgets
  class Test_MultidateWidget < BureaucratTestCase
    def test_renders_nothing
      widget = Bureaucrat::Widgets::MultiDate.new
      html =  widget.render("my_name", {})
      assert_equal("", html)
    end

    def test_renders_one_month
      widget = Bureaucrat::Widgets::MultiDate.new(nil, months: [['first_month', 'My First Month']])
      html =  widget.render("my_name", {})
      assert_equal("<select name=\"my_name[month]\">\n<option value=\"first_month\">My First Month</option>\n</select>", html)
    end

    def test_renders_one_month_with_default_attrs
      widget = Bureaucrat::Widgets::MultiDate.new({month: {class: 'super'}}, months: [['first_month', 'My First Month']])
      html =  widget.render("my_name", {})
      assert_equal("<select class=\"super\" name=\"my_name[month]\">\n<option value=\"first_month\">My First Month</option>\n</select>", html)
    end

    def test_renders_one_month_with_custom_attrs
      widget = Bureaucrat::Widgets::MultiDate.new({month: {class: 'super'}}, months: [['first_month', 'My First Month']])
      html =  widget.render("my_name", {}, {month: {class: 'super duper'}})
      assert_equal("<select class=\"super duper\" name=\"my_name[month]\">\n<option value=\"first_month\">My First Month</option>\n</select>", html)
    end

    def test_renders_one_month_with_selected_values
      widget = Bureaucrat::Widgets::MultiDate.new(nil, months: [['first_month', 'My First Month']])
      html =  widget.render("my_name", {month: 'first_month'})
      assert_equal("<select name=\"my_name[month]\">\n<option value=\"first_month\" selected=\"selected\">My First Month</option>\n</select>", html)
    end

    def test_renders_two_months_with_selected_values
      widget = Bureaucrat::Widgets::MultiDate.new(nil, months: [['first_month', 'My First Month'], ['second_month', 'My Second Month']])
      html =  widget.render("my_name", {month: 'first_month'})
      assert_equal("<select name=\"my_name[month]\">\n<option value=\"first_month\" selected=\"selected\">My First Month</option>\n<option value=\"second_month\">My Second Month</option>\n</select>", html)
    end

    def test_renders_one_day
      widget = Bureaucrat::Widgets::MultiDate.new(nil, days: [['1', 'one']])
      html =  widget.render("my_name", {})
      assert_equal("<select name=\"my_name[day]\">\n<option value=\"1\">one</option>\n</select>", html)
    end

    def test_renders_one_day_with_default_attrs
      widget = Bureaucrat::Widgets::MultiDate.new({day: {class: 'super'}}, days: [['first_day', 'My First day']])
      html =  widget.render("my_name", {})
      assert_equal("<select class=\"super\" name=\"my_name[day]\">\n<option value=\"first_day\">My First day</option>\n</select>", html)
    end

    def test_renders_one_day_with_custom_attrs
      widget = Bureaucrat::Widgets::MultiDate.new({day: {class: 'super'}}, days: [['first_day', 'My First day']])
      html =  widget.render("my_name", {}, {day: {class: 'super duper'}})
      assert_equal("<select class=\"super duper\" name=\"my_name[day]\">\n<option value=\"first_day\">My First day</option>\n</select>", html)
    end

    def test_renders_one_day_with_selected_values
      widget = Bureaucrat::Widgets::MultiDate.new(nil, days: [['first_day', 'My First day']])
      html =  widget.render("my_name", {day: 'first_day'})
      assert_equal("<select name=\"my_name[day]\">\n<option value=\"first_day\" selected=\"selected\">My First day</option>\n</select>", html)
    end

    def test_renders_two_days_with_selected_values
      widget = Bureaucrat::Widgets::MultiDate.new(nil, days: [['first_day', 'My First day'], ['second_day', 'My Second day']])
      html =  widget.render("my_name", {day: 'first_day'})
      assert_equal("<select name=\"my_name[day]\">\n<option value=\"first_day\" selected=\"selected\">My First day</option>\n<option value=\"second_day\">My Second day</option>\n</select>", html)
    end

    def test_renders_one_year
      widget = Bureaucrat::Widgets::MultiDate.new(nil, years: [['1', 'one']])
      html =  widget.render("my_name", {})
      assert_equal("<select name=\"my_name[year]\">\n<option value=\"1\">one</option>\n</select>", html)
    end

    def test_renders_one_year_with_default_attrs
      widget = Bureaucrat::Widgets::MultiDate.new({year: {class: 'super'}}, years: [['first_year', 'My First year']])
      html =  widget.render("my_name", {})
      assert_equal("<select class=\"super\" name=\"my_name[year]\">\n<option value=\"first_year\">My First year</option>\n</select>", html)
    end

    def test_renders_one_year_with_custom_attrs
      widget = Bureaucrat::Widgets::MultiDate.new({year: {class: 'super'}}, years: [['first_year', 'My First year']])
      html =  widget.render("my_name", {}, {year: {class: 'super duper'}})
      assert_equal("<select class=\"super duper\" name=\"my_name[year]\">\n<option value=\"first_year\">My First year</option>\n</select>", html)
    end

    def test_renders_one_year_with_selected_values
      widget = Bureaucrat::Widgets::MultiDate.new(nil, years: [['first_year', 'My First year']])
      html =  widget.render("my_name", {year: 'first_year'})
      assert_equal("<select name=\"my_name[year]\">\n<option value=\"first_year\" selected=\"selected\">My First year</option>\n</select>", html)
    end

    def test_renders_two_years_with_selected_values
      widget = Bureaucrat::Widgets::MultiDate.new(nil, years: [['first_year', 'My First year'], ['second_year', 'My Second year']])
      html =  widget.render("my_name", {year: 'first_year'})
      assert_equal("<select name=\"my_name[year]\">\n<option value=\"first_year\" selected=\"selected\">My First year</option>\n<option value=\"second_year\">My Second year</option>\n</select>", html)
    end

    def test_renders_date
      widget = Bureaucrat::Widgets::MultiDate.new(nil, years: [[1988, 'My First year']],
                                                 months: [[11, 'My First month']],
                                                 days: [[1, 'My day']])
      html =  widget.render("my_name", Date.parse('1/11/1988'))
      assert_equal("<select name=\"my_name[month]\">\n<option value=\"11\" selected=\"selected\">My First month</option>\n</select><select name=\"my_name[day]\">\n<option value=\"1\" selected=\"selected\">My day</option>\n</select><select name=\"my_name[year]\">\n<option value=\"1988\" selected=\"selected\">My First year</option>\n</select>", html)
    end

    def test_creates_a_date_value
      widget = Bureaucrat::Widgets::MultiDate.new
      value = widget.value_from_formdata({date: {'month' =>'11', 'day' => '1', 'year' => '1988'}}, :date)
      assert_equal(11, value.month)
      assert_equal(1, value.day)
      assert_equal(1988, value.year)
    end

    def test_handles_invalid_month
      widget = Bureaucrat::Widgets::MultiDate.new
      date = {'month' => '', 'day' => '1', 'year' => '1988'}
      value = widget.value_from_formdata({date: date}, :date)
      assert_equal(date, value)
    end

    def test_handles_invalid_day
      widget = Bureaucrat::Widgets::MultiDate.new
      date = {'month' => '11', 'day' => '', 'year' => '1988'}
      value = widget.value_from_formdata({date: date}, :date)
      assert_equal(date, value)
    end

    def test_handles_invalid_day
      widget = Bureaucrat::Widgets::MultiDate.new
      date = {'month' => '11', 'day' => '1', 'year' => ''}
      value = widget.value_from_formdata({date: date}, :date)
      assert_equal(date, value)
    end

    def test_handles_dates
      widget = Bureaucrat::Widgets::MultiDate.new
      date = Date.today
      expected_date = {month: date.month, day: date.day, year: date.year}
      value = widget.value_from_formdata({date: date}, :date)
      assert_equal(expected_date, value)
    end
  end
end
