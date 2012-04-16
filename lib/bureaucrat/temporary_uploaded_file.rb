module Bureaucrat
  class TemporaryUploadedFile
    attr_accessor :filename, :content_type, :name, :tempfile, :head, :size

    def initialize(data)
      @filename = data[:filename]
      @content_type = data[:content_type]
      @name = data[:name]
      @tempfile = data[:tempfile]
      @size = @tempfile.size
      @head = data[:head]
    end
  end
end
