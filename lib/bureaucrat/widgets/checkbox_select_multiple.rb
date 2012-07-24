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
        final_attrs = build_attrs(attrs, name: multi_name)
        output = ['<ul>']
        str_values = {}
        values.each {|val| str_values[(val.to_s)] = true}

        (@choices.to_a + choices.to_a).each_with_index do |opt_pair, i|
            opt_val, opt_label = opt_pair
            if has_id
              final_attrs[:id] = "#{attrs[:id]}_#{i}"
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
          end
        output << '</ul>'
        mark_safe(output.join("\n"))
      end
    end
  end
end
