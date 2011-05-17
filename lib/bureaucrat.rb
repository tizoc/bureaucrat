module Bureaucrat
  VERSION = '0.10.0'

  class ValidationError < Exception
    attr_reader :code, :params, :messages

    def initialize(message, code = nil, params = nil)
      if message.is_a? Array
        @messages = message
      else
        @code = code
        @params = params
        @messages = [message]
      end
    end

    def to_s
      "ValidationError(#{@messages.inspect})"
    end
  end

  autoload :Fields,      'bureaucrat/fields'
  autoload :Forms,       'bureaucrat/forms'
  autoload :Utils,       'bureaucrat/utils'
  autoload :Validators,  'bureaucrat/validators'
  autoload :Widgets,     'bureaucrat/widgets'
  autoload :TemporaryUploadedFile, 'bureaucrat/temporary_uploaded_file'

  # Extra
  autoload :Formsets,    'bureaucrat/formsets'
  autoload :Quickfields, 'bureaucrat/validation'
end
