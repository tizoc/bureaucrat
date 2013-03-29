require 'bureaucrat/temporary_uploaded_file'

class MockUploadedFile
  attr_reader :original_filename, :content_type, :tempfile, :headers
  def initialize(original_filename, content_type, tempfile, headers)
    @original_filename = original_filename
    @content_type = content_type
    @tempfile = tempfile
    @headers = headers
  end
end

class MockTempfile
  def size
    166
  end
end

describe Bureaucrat::TemporaryUploadedFile do
  let(:original_filename) {'the filename'}
  let(:content_type)      {'Content/jpg'}
  let(:headers)           {'mock headers'}

  it 'assumes the ActionDispatch::Http::UploadedFile interface' do
    tempfile = MockTempfile.new
    file = MockUploadedFile.new(original_filename, content_type, tempfile, headers)
    temporary_uploaded_file = described_class.new(file)

    temporary_uploaded_file.filename.should     == original_filename
    temporary_uploaded_file.content_type.should == content_type
    temporary_uploaded_file.tempfile.should     == tempfile
    temporary_uploaded_file.name.should         == original_filename
    temporary_uploaded_file.size.should         == tempfile.size
    temporary_uploaded_file.head.should         == headers
  end
end
