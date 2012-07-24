require 'bureaucrat/fields/field'
require 'bureaucrat/widgets/clearable_file_input'

module Bureaucrat
  module Fields
    class FileField < Field
      def initialize(options)
        @max_length = options[:max_length]
        @allow_empty_file = options[:allow_empty_file]
        super(options)
      end

      def default_error_messages
        super.merge(invalid: error_message(:file, :invalid),
                    missing: error_message(:file, :missing),
                    empty: error_message(:file, :empty),
                    max_length: error_message(:file, :max_length),
                    contradiction: error_message(:file, :contradiction))
      end

      def default_widget
        Widgets::ClearableFileInput
      end

      def to_object(data)
        if data.blank?
          return nil
        end

        # UploadedFile objects should have name and size attributes.
        begin
          file_name = data.name
          file_size = data.size
        rescue NoMethodError
          raise ValidationError.new(error_messages[:invalid])
        end

        if @max_length && file_name.length > @max_length
          msg = Utils.format_string(error_messages[:max_length],
                                    max: @max_length,
                                    length: file_name.length)
          raise ValidationError.new(msg)
        end

        if Utils.blank_value?(file_name)
          raise ValidationError.new(error_messages[:invalid])
        end

        if !@allow_empty_file && !file_size
          raise ValidationError.new(error_messages[:empty])
        end

        data
      end

      def clean(data, initial = nil)
        # If the widget got contradictory inputs, we raise a validation error
        if data.object_id ==  Widgets::ClearableFileInput::FILE_INPUT_CONTRADICTION.object_id
          raise ValidationError.new(error_messages[:contradiction])
        end

        # False means the field value should be cleared; further validation is
        # not needed.
        if data == false
          unless @required
            return false
          end

          # If the field is required, clearing is not possible (the widget
          # shouldn't return false data in that case anyway). false is not
          # an 'empty_value'; if a false value makes it this far
          # it should be validated from here on out as nil (so it will be
          # caught by the required check).
          data = nil
        end

        if !data && initial
          initial
        else
          super(data)
        end
      end

      def bound_data(data, initial)
        if data.nil? || data.object_id == Widgets::ClearableFileInput::FILE_INPUT_CONTRADICTION.object_id
          initial
        else
          data
        end
      end
    end
  end
end
