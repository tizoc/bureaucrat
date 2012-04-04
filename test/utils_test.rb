require_relative 'test_helper'

class TestUtils < BureaucratTestCase
  describe 'OrderedHash' do
    setup do
      @hash = Utils::OrderedHash.new
      @hash[:first] = "able"
      @hash[:second] = "baker"
      @hash[:third] = "charlie"
      @hash[:fourth] = "delta"
    end

    should 'iterate in order' do
      expected = [:first, "able", :second, "baker", :third, "charlie", :fourth, "delta"]
      actual = []
      @hash.each do |k,v|
        actual << k
        actual << v
      end
      assert_equal(expected, actual)
    end

    should 'have deletable items' do
      expected = [:first, "able", :third, "charlie", :fourth, "delta"]
      actual = []
      @hash.delete :second
      @hash.each do |k,v|
        actual << k
        actual << v
      end
      assert_equal(expected, actual)
    end
  end
end
