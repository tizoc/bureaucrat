require 'bureaucrat/widgets/widget'

module Bureaucrat
  module Widgets
    class TimeSlotWidget < Widget

      DAYS_OF_THE_WEEK = [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
      TIME_SLOTS = [:early_morning, :late_morning, :early_afternoon, :late_afternoon, :early_evening, :late_evening, :overnight]

      def render(name, value, attrs={})
        value = normalize_for_view(value)
        html = ""
        html << "<table id='#{attrs[:id]}' >"
        html << "<thead>"
        html << "<tr>"
        html << "<td></td>"
        DAYS_OF_THE_WEEK.each do |day|
          html << "<td>#{I18n.t("bureaucrat.#{form_name}.#{name}.days.#{day}")}</td>"
        end
        html << "</tr>"
        html << "</thead>"
        html << "<tbody>"
        TIME_SLOTS.each do |time_slot|
          html << '<tr>'
          html << "<td>#{I18n.t("bureaucrat.#{form_name}.#{name}.time_slots.#{time_slot}")}</td>"
          time_slot_value = value[time_slot.to_s] || {}
          DAYS_OF_THE_WEEK.each do |day|
            widget = Bureaucrat::Widgets::CheckboxInput.new
            html << "<td>#{widget.render("#{name}[#{time_slot}][#{day}]", time_slot_value[day.to_s], {value: 'true'})}</td>"
          end
          html << '</tr>'
        end
        html << "</tbody>"
        html << "</table>"
        html
      end

      def normalize_for_view(data)
        data ||= {}
        data.reduce({}) do |normalized, (time_slot, value)|
          if value.is_a? Hash
            normalized[time_slot] = value
          elsif value.is_a? Array
            normalized[time_slot] ||= {}
            value.each do |day|
              normalized[time_slot][day] = true
            end
          end
          normalized
        end
      end
    end
  end
end
