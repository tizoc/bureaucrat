require 'bureaucrat/fields/field'

module Bureaucrat
  module Fields
    class ComboField < Field
      def initialize(fields=[], *args)
        super(*args)
        fields.each {|f| f.required = false}
        @fields = fields
      end

      def clean(value)
        super(value)
        @fields.each {|f| value = f.clean(value)}
        value
      end
    end
  end
end
