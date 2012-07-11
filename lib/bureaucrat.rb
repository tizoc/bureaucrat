$: << File.expand_path('..', __FILE__)

require 'i18n'

root = File.expand_path('../..', __FILE__)
I18n.load_path += Dir[File.join(root, 'locales', '**', '*.yml').to_s]

module Bureaucrat
  VERSION = '0.11.2'

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
