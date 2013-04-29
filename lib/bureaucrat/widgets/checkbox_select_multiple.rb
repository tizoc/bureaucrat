require 'bureaucrat/widgets/select_multiple'

module Bureaucrat
  module Widgets
    class CheckboxSelectMultiple < SelectMultiple
      def self.id_for_label(id_)
        id_.empty? ? id_ : id_ + '_0'
      end

      def render(name, values, attrs=nil, choices=[])
        values ||= []
        multi_name = "#{name}[]"
        has_id = attrs && attrs.include?(:id)
        columns = @attrs.delete(:columns) { 1 }
        final_attrs = build_attrs(attrs, name: multi_name)
        output = []
        str_values = {}
        values.each {|val| str_values[(val.to_s)] = true}

        choice_index = 0
        choice_collection(@choices.to_a + choices.to_a, columns).each_with_index do |coll, column_index|
          output << "<ul#{column_class(columns, column_index)}>"
          coll.each do |opt_pair|
            opt_val, opt_label = opt_pair
            if has_id
              final_attrs[:id] = "#{attrs[:id]}_#{choice_index}"
              label_for = " for=\"#{final_attrs[:id]}\""
            else
              label_for = ''
            end

            check_test = lambda{|value| str_values[value]}
            cb = CheckboxInput.new(final_attrs, check_test)
            opt_val = opt_val.to_s
            rendered_cb = cb.render(multi_name, opt_val)
            opt_label = conditional_escape(opt_label.to_s)
            output << "<li><label#{label_for}>#{rendered_cb} #{opt_label}</label></li>"
            choice_index += 1
          end
          output << '</ul>'
        end
        mark_safe(output.join("\n"))
      end

      private

      def choice_collection(choices, columns)
        if columns > 1
          choices.partition {|x| choices.index(x) < choices.length/2.0}
        else
          [choices]
        end
      end

      def column_class(columns, column_index)
        if columns > 1
          " class=\"column-#{column_index}\""
        else
          ''
        end
      end
    end
  end
end
