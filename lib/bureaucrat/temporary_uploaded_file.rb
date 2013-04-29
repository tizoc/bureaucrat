module Bureaucrat
  class TemporaryUploadedFile
    attr_accessor :filename, :content_type, :name, :tempfile, :head, :size

    def initialize(data)
      @filename = data.original_filename
      @content_type = data.content_type
      @tempfile = data.tempfile
      @name = @filename
      @size = @tempfile.size
      @head = data.headers
    end
  end
end
