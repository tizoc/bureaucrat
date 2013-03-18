require 'bureaucrat/widgets/input'
require 'bureaucrat/temporary_uploaded_file'

module Bureaucrat
  module Widgets
    class FileInput < Input
      def render(name, value, attrs=nil)
        super(name, nil, attrs)
      end

      def value_from_formdata(data, name)
        data[name] && TemporaryUploadedFile.new(data[name])
      end

      def has_changed?(initial, data)
        data.nil?
      end

      def input_type
        'file'
      end

      def needs_multipart?
        true
      end
    end
  end
end
