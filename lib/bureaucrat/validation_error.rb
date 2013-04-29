module Bureaucrat
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
end
