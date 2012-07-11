require 'bureaucrat/fields/field'

module Bureaucrat
  module Fields
    class CharField < Field
      attr_accessor :max_length, :min_length

      def initialize(options = {})
        @max_length = options.delete(:max_length)
        @min_length = options.delete(:min_length)
        super(options)

        if @min_length
          validators << Validators::MinLengthValidator.new(@min_length)
        end

        if @max_length
          validators << Validators::MaxLengthValidator.new(@max_length)
        end
      end

      def to_object(value)
        if Validators.empty_value?(value)
          ''
        else
          value
        end
      end

      def widget_attrs(widget)
        super(widget).tap do |attrs|
          if @max_length && (widget.kind_of?(Widgets::TextInput) ||
                             widget.kind_of?(Widgets::PasswordInput))
            attrs.merge(maxlength: @max_length.to_s)
          end
        end
      end
    end
  end
end
