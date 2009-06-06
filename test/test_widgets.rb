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

  describe 'PasswordInput widget' do
    describe 'with render_value=true' do
      should 'render correctly including value' do
        input = Widgets::PasswordInput.new
        excepted = normalize_html("<input name='test' type='password' value='secret'/>")
        rendered = normalize_html(input.render('test', 'secret'))
        assert_equal(excepted, rendered)
      end
    end

    describe 'with render_value=false' do
      should 'render correctly not including value' do
        input = Widgets::PasswordInput.new(nil, false)
        excepted = normalize_html("<input name='test' type='password'/>")
        rendered = normalize_html(input.render('test', 'secret'))
        assert_equal(excepted, rendered)
      end
    end
  end

  describe 'HiddenInput widget' do
    should 'correctly render' do
      input = Widgets::HiddenInput.new
      excepted = normalize_html("<input name='test' type='hidden' value='secret'/>")
      rendered = normalize_html(input.render('test', 'secret'))
      assert_equal(excepted, rendered)
    end
  end

  describe 'MultipleHiddenInput widget' do
    should 'correctly render' do
      input = Widgets::MultipleHiddenInput.new
      excepted = normalize_html("<input name='test' type='hidden' value='v1'/>\n<input name='test' type='hidden' value='v2'/>")
      rendered = normalize_html(input.render('test', ['v1', 'v2']))
      assert_equal(excepted, rendered)
    end
    # TODO: value_from_datahash
  end

  describe 'FileInput widget' do
    should 'correctly render' do
      input = Widgets::FileInput.new
      excepted = normalize_html("<input name='test' type='file'/>")
      rendered = normalize_html(input.render('test', "anything"))
      assert_equal(excepted, rendered)
    end
    # TODO: value_from_datahash, has_changed?
  end

  describe 'Textarea widget' do
    should 'correctly render' do
      input = Widgets::Textarea.new(:cols => '50', :rows => '15')
      excepted = normalize_html("<textarea name='test' rows='15' cols='50'>hello</textarea>")
      rendered = normalize_html(input.render('test', "hello"))
      assert_equal(excepted, rendered)
    end
  end

  describe 'CheckboxInput widget' do
    should 'correctly render with a false value' do
      input = Widgets::CheckboxInput.new
      excepted = normalize_html("<input name='test' type='checkbox' value='false'/>")
      rendered = normalize_html(input.render('test', 'false'))
      assert_equal(excepted, rendered)
    end

    should 'correctly render with a true value' do
      input = Widgets::CheckboxInput.new
      excepted = normalize_html("<input name='test' type='checkbox' value='true'/>")
      rendered = normalize_html(input.render('test', 'true'))
      assert_equal(excepted, rendered)
    end

    should 'correctly render with a non boolean value' do
      input = Widgets::CheckboxInput.new
      excepted = normalize_html("<input name='test' type='checkbox' value='anything'/>")
      rendered = normalize_html(input.render('test', 'anything'))
      assert_equal(excepted, rendered)
    end
    # TODO: value_from_datahash, has_changed?
  end

  describe 'Select widget' do
    def setup
      @choices = [['1', 'One'], ['2', 'Two']]
      @groupchoices = [['numbers', ['1', 'One'], ['2', 'Two']],
                       ['words', [['spoon', 'Spoon'], ['banana', 'Banana']]]]
    end

    describe 'with empty choices' do
      should 'correctly render' do
        input = Widgets::Select.new
        excepted = normalize_html("<select name='test'>\n</select>")
        rendered = normalize_html(input.render('test', 'hello'))
        assert_equal(excepted, rendered)
      end
    end

    describe 'with flat choices' do
      should 'correctly render (none selected)' do
        input = Widgets::Select.new(nil, @choices)
        excepted = normalize_html("<select name='test'>\n<option value='1'>One</option>\n<option value='2'>Two</option>\n</select>")
        rendered = normalize_html(input.render('test', 'hello'))
        assert_equal(excepted, rendered)
      end

      should 'correctly render (with selected)' do
        input = Widgets::Select.new(nil, @choices)
        excepted = normalize_html("<select name='test'>\n<option value='1'>One</option>\n<option value='2' selected='selected'>Two</option>\n</select>")
        rendered = normalize_html(input.render('test', '2'))
        assert_equal(excepted, rendered)
      end
    end

    describe 'with group choices' do
      should 'correctly render (none selected)' do
        input = Widgets::Select.new(nil, @groupchoices)
        excepted = normalize_html("<select name='test'>\n<optgroup label='numbers'>\n<option value='1'/>\n<option value='One'/>\n</optgroup>\n<optgroup label='words'>\n<option value='spoon'>Spoon</option>\n<option value='banana'>Banana</option>\n</optgroup>\n</select>")
        rendered = normalize_html(input.render('test', 'hello'))
        assert_equal(excepted, rendered)
      end

      should 'correctly render (with selected)' do
        input = Widgets::Select.new(nil, @groupchoices)
        excepted = normalize_html("<select name='test'>\n<optgroup label='numbers'>\n<option value='1'/>\n<option value='One'/>\n</optgroup>\n<optgroup label='words'>\n<option value='spoon'>Spoon</option>\n<option value='banana' selected='selected'>Banana</option>\n</optgroup>\n</select>")
        rendered = normalize_html(input.render('test', 'banana'))
        assert_equal(excepted, rendered)
      end
    end
  end

  describe 'NullBooleanSelect widget' do
    should 'correctly render with "Unknown" as the default value when none is selected' do
      input = Widgets::NullBooleanSelect.new
      excepted = normalize_html("<select name='test'>\n<option selected='selected' value='1'>Unknown</option>\n<option value='2'>Yes</option>\n<option value='3'>No</option>\n</select>")
      rendered = normalize_html(input.render('test', nil))
      assert_equal(excepted, rendered)
    end

    should 'correctly render (with selected)' do
      input = Widgets::NullBooleanSelect.new
      excepted = normalize_html("<select name='test'>\n<option value='1'>Unknown</option>\n<option selected='selected' value='2'>Yes</option>\n<option value='3'>No</option>\n</select>")
      rendered = normalize_html(input.render('test', '2'))
      assert_equal(excepted, rendered)
    end
  end
end
