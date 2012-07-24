require 'bureaucrat/fields/field'
require 'bureaucrat/widgets/range'

module Bureaucrat
  module Fields
    class RangeField < Field
      def initialize(options)
        super(options)
        sub_field = options[:sub_field] || default_sub_field
        @min = sub_field.new(options)
        @max = sub_field.new(options)
      end

      def default_sub_field
        IntegerField
      end

      def form_name=(form_name)
        super(form_name)
        @min.form_name = form_name
        @max.form_name = form_name
      end

      def name=(name)
        super(name)
        @max.name = name
        @min.name = name
      end

      def clean(value)
        value ||= {}
        value['min'] = @min.clean(value['min'])
        value['max'] = @max.clean(value['max'])

        non_nil_fields_count = [value['min'],value['max']].count{|field| !field.nil?}

        if non_nil_fields_count == 1
          raise ValidationError.new(error_message("range", :needs_both_fields))
        elsif non_nil_fields_count == 2
          raise ValidationError.new(error_message("range", :reversed)) if value['min'] > value['max']
        end

        super(value)
      end

      def to_object(value)
        value
      end

      def default_widget
        Widgets::Range
      end
    end
  end
end

