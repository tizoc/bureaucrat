require 'bureaucrat/fields/field'
require 'bureaucrat/validators/max_length'
require 'bureaucrat/validators/min_length'
require 'bureaucrat/widgets/text_input'
require 'bureaucrat/widgets/password_input'

module Bureaucrat
  module Fields
    class CharField < Field
      attr_accessor :max_length, :min_length

      def initialize(options = {})
        @max_length = options[:max_length]
        @min_length = options[:min_length]
        super(options)

        if @min_length
          validators << Validators::MinLengthValidator.new(@min_length)
        end

        if @max_length
          validators << Validators::MaxLengthValidator.new(@max_length)
        end
      end

      def default_error_messages
        super.merge(
          max_length: error_message(:char, :max_length, {max: @max_length}),
          min_length: error_message(:char, :min_length, {min: @min_length})
        )
      end

      def to_object(value)
        if value.blank?
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
