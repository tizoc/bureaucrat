require 'bureaucrat/fields/field'
require 'bureaucrat/widgets/time_slot'

module Bureaucrat
  module Fields
    class TimeSlotField < Field
      def clean(value)
        value ||= {}
        unless value.any? { |time_slot, days| !days.empty? }
          raise Bureaucrat::ValidationError.new(error_message(name, :required))
        end
        value.reduce({}) do |time_slots, (time_slot, availability)|
          time_slots[time_slot] = availability.reduce([]) do |days, (day, available)|
          days << day if available == 'true'
          days
        end
        time_slots
        end
      end

      def default_widget
        Widgets::TimeSlotWidget
      end
    end
  end
end
