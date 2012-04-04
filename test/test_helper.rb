require 'bigdecimal'
require 'minitest/autorun'

require_relative '../lib/bureaucrat'
require_relative '../lib/bureaucrat/formsets'

# Used to compare rendered htmls
require 'rexml/document'

class BureaucratTestCase < MiniTest::Unit::TestCase
  include Bureaucrat

  class << self
    def setup(&block)
      setup_blocks << block
    end
    
    def describe(name, &block)
      subclass = Class.new(self.superclass)
      subclass.setup_blocks.unshift(*setup_blocks)
      subclass.class_eval(&block)
      const_set(context_name(name), subclass)
    end

    def should(name, &block)
      define_method(test_name(name), &block)
    end

    def setup_blocks
      @setup_blocks ||= []
    end

    def context_name(name)
      "Test#{sanitize_name(name).gsub(/(^| )(\w)/) { $2.upcase }}".to_sym
    end

    def test_name(name)
      "test_#{sanitize_name(name).gsub(/\s+/,'_')}".to_sym
    end

    def sanitize_name(name)
      name.gsub(/\W+/, ' ').strip
    end
  end

  def setup
    self.class.setup_blocks.each do |block|
      instance_eval(&block)
    end
  end

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
    rescue Exception => e
      html
    end
  end
end
