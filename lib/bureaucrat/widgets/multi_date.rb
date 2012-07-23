module Bureaucrat
  module Widgets
    class MultiDate < Widget
      def initialize(given_attrs={}, choices={})
        super(given_attrs)
        choices ||= {}
        @month_choices = choices[:months] || []
        @month = Select.new(attrs[:month], @month_choices)
        @day_choices = choices[:days] || []
        @day = Select.new(attrs[:day], @day_choices)
        @year_choices = choices[:years] || []
        @year = Select.new(attrs[:year], @year_choices)
      end

      def render(name, value, attrs={})
        month, day, year = destructure_date(value)
        html = ""
        unless @month_choices.empty?
          html << @month.render("#{name}[month]", month, attrs[:month])
        end
        unless @day_choices.empty?
          html << @day.render("#{name}[day]", day, attrs[:day])
        end
        unless @year_choices.empty?
          html << @year.render("#{name}[year]", year, attrs[:year])
        end
        html
      end

      def value_from_formdata(data, name)
        data = data[name] || {}
        begin
          Date.strptime("#{data['day']}-#{data['month']}-#{data['year']}", '%d-%m-%Y')
        rescue ArgumentError
          return data
        end
      end

      def destructure_date(date)
        date ||= {}
        if date.is_a?(Date)
          [date.month, date.day, date.year]
        else
          [date[:month], date[:day], date[:year]]
        end
      end
    end
  end
end
