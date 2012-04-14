require 'bigdecimal'
require 'minitest/autorun'

require_relative '../lib/bureaucrat'
require_relative '../lib/bureaucrat/formsets'

# Used to compare rendered htmls
require 'rexml/document'

class BureaucratTestCase < MiniTest::Unit::TestCase
  include Bureaucrat

  def assert_nothing_raised(&block)
    block.call
    assert true
  end

  def assert_not_equal(value, other)
    assert value != other, "should be different from #{value}"
  end

  def normalize_html(html)
    begin
      node = REXML::Document.new("<DUMMYROOT>#{html.strip}</DUMMYROOT>")
      node.to_s.gsub!(/<\/?DUMMYROOT>/, '')
    rescue
      html
    end
  end
end
