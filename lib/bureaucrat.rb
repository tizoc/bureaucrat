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

  require_relative 'bureaucrat/utils'
  require_relative 'bureaucrat/validators'
  require_relative 'bureaucrat/widgets'
  require_relative 'bureaucrat/fields'
  require_relative 'bureaucrat/forms'
  require_relative 'bureaucrat/temporary_uploaded_file'
end
