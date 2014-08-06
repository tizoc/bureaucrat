require 'minitest/autorun'
require 'i18n'

# Used to compare rendered htmls
require 'rexml/document'


root = File.expand_path('../..', __FILE__)
I18n.load_path += Dir[File.join(root, 'test', 'locales', '**', '*.yml').to_s]

class BureaucratTestCase < MiniTest::Unit::TestCase

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
