libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

module Bureaucrat
  VERSION = '0.0.1'
end

require 'bureaucrat/widgets'
require 'bureaucrat/fields'
require 'bureaucrat/forms'
