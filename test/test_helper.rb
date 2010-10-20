require 'bigdecimal'
require 'rubygems'
require "contest"

$:.unshift(File.expand_path("../lib", File.dirname(__FILE__)))

require 'bureaucrat'
require 'bureaucrat/formsets'

# Used to compare rendered htmls
require 'rexml/document'

class BureaucratTestCase < Test::Unit::TestCase
  include Bureaucrat
end

def normalize_html(html)
  begin
    node = REXML::Document.new("<DUMMYROOT>#{html.strip}</DUMMYROOT>")
    node.to_s.gsub!(/<\/?DUMMYROOT>/, '')
  rescue Exception => e
    html
  end
end
