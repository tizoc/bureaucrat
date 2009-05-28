require 'rubygems'
require "contest"

require File.join(File.dirname(__FILE__), '..', 'lib', 'bureaucrat')

# Used to compare rendered htmls
require 'rexml/document'

class BureaucratTestCase < Test::Unit::TestCase
  include Bureaucrat
end

def normalize_html(html)
  begin
    node = REXML::Document.new("<DUMMYROOT>#{html}</DUMMYROOT>")
    node.to_s.gsub!(/<\/?DUMMYROOT>/, '')
  rescue Exception => e
    html
  end
end
