require File.dirname(__FILE__) + "/test_helper"

class TestWidgets < BureaucratTestCase
  describe 'Media' do
    describe 'empty' do
      setup do
        @media = Widgets::Media.new
      end

      should 'render an empty string' do
        rendered = @media.render
        assert_equal('', rendered)
      end
    end

    describe 'with only javascript' do
      setup do
        @media = Widgets::Media.new(:js => ['test.js', 'test2.js'])
      end

      should 'render correctly and in same order' do
        rendered = @media.render
        expected = "<script type=\"text/javascript\" src=\"http://localhost/test.js\"></script>\n<script type=\"text/javascript\" src=\"http://localhost/test2.js\"></script>"
        assert_equal(expected, rendered)
      end
    end

    describe 'with only css' do
      setup do
        @media = Widgets::Media.new(:css => {:screen => ['test.css',
                                                         'test2.css']})
      end

      should 'render correctly' do
        rendered = @media.render
        expected = "<link href=\"http://localhost/test.css\" type=\"text/css\" media=\"screen\" rel=\"stylesheet\" />\n<link href=\"http://localhost/test2.css\" type=\"text/css\" media=\"screen\" rel=\"stylesheet\" />"
        assert_equal(expected, rendered)
      end
    end

    describe 'with both js and css' do
      setup do
        @media = Widgets::Media.new(:js => ['test.js', 'test2.js'],
                                    :css => {:screen => ['test.css',
                                                         'test2.css']})
      end

      should 'render correctly' do
        rendered = @media.render
        expected = "<link href=\"http://localhost/test.css\" type=\"text/css\" media=\"screen\" rel=\"stylesheet\" />\n<link href=\"http://localhost/test2.css\" type=\"text/css\" media=\"screen\" rel=\"stylesheet\" />\n<script type=\"text/javascript\" src=\"http://localhost/test.js\"></script>\n<script type=\"text/javascript\" src=\"http://localhost/test2.js\"></script>"
        assert_equal(expected, rendered)
      end
    end

    describe 'the result of summing two instances of Media' do
      setup do
        @media1 = Widgets::Media.new(:js => ['test1.js', 'test2.js'],
                                     :css => {:screen => ['test1.css',
                                                          'test2.css']})
        @media2 = Widgets::Media.new(:js => ['test3.js', 'test4.js'],
                                     :css => {:screen => ['test3.css',
                                                          'test4.css']})
        @combined = @media1 + @media2
      end

      should 'be an instance of Media' do
        assert_kind_of(Widgets::Media, @combined)
      end

      should 'contain a combined list of js' do
        expected = @media1.to_hash[:js] + @media2.to_hash[:js]
        result = @combined.to_hash[:js]
        assert_equal(expected, result)
      end

      should 'contain a combined list of css' do
        expected = @media1.to_hash[:css]
        @media2.to_hash[:css].each do |k, v|
          expected[k] ||= []
          expected[k] += v
        end
        result = @combined.to_hash[:css]
        assert_equal(expected, result)
      end
    end
  end

  describe 'Widget instance' do
    should 'return an instance of Media when calling #media' do
      widget = Widgets::Widget.new
      assert_kind_of(Widgets::Media, widget.media)
    end
  end

  describe 'TextInput widget' do

    describe 'with empty attributes' do
      should 'correctly render' do
        input = Widgets::TextInput.new
        expected = normalize_html('<input type="text" value="hi" name="test" />')
        rendered = normalize_html(input.render('test', 'hi'))
        assert_equal(expected, rendered)
      end
    end

    describe 'with attributes' do
      should 'correctly render' do
        input = Widgets::TextInput.new(:attribute => 'value')
        expected = normalize_html('<input type="text" value="hi" name="test" attribute="value" />')
        rendered = normalize_html(input.render('test', 'hi'))
        assert_equal(expected, rendered)
      end
    end

    describe 'without value' do
      should 'not render a value' do
        input = Widgets::TextInput.new
        expected = normalize_html('<input type="text" name="test" />')
        rendered = normalize_html(input.render('test', nil))
        assert_equal(expected, rendered)
      end
    end

    describe 'when copied' do
      should 'have a copy of the attributes' do
        input1 = Widgets::TextInput.new(:attribute => 2)
        input2 = input1.dup
        assert_not_equal(input1.attrs.object_id, input2.attrs.object_id)
      end
    end
  end
end
