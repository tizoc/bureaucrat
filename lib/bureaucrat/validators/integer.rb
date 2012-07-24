module Bureaucrat
  module Validators
     ValidateInteger = lambda do |value|
      begin
        Integer(value)
      rescue ArgumentError
        raise ValidationError.new('')
      end
    end
  end
end
