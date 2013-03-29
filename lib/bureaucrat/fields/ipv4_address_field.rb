require 'bureaucrat/fields/regex_field'

module Bureaucrat
  module Fields
    class Ipv4AddressField < RegexField
      IPV4 = /^(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3}$/

      def initialize(options={})
        super(IPV4, options)
      end

      def clean(value)
        value = to_object(value).strip
        super(value)
      end
    end
  end
end
