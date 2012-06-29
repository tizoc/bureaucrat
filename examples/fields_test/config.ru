require 'erb'
require 'bigdecimal'
require 'prettyprint'
require 'rack'
require 'bureaucrat'
require 'bureaucrat/quickfields'

class TestForm1 < Bureaucrat::Forms::Form
  extend Bureaucrat::Quickfields

  string       :string_field
  string       :string_field2, :required => false,\
               :label => 'Another String'
  text         :text_field
  password     :password, :required => false
  password     :password_confirmation, :required => false
  integer      :integer
  decimal      :decimal
  regex        :regex, /\w\d\d\w+/, :help_text => '\w\d\d\w+'
  email        :email
  #file         :file, :required => false
  boolean      :boolean
  null_boolean :null_boolean
  choice       :choice, [['', 'Select a letter'],
                         ['a', 'Letter A'],
                         ['b', 'Letter B']]
  multiple_choice :multiple_choice, [['', 'Select some letters'],
                                     ['a', 'Letter A'],
                                     ['b', 'Letter B'],
                                     ['c', 'Letter C']]
  radio_choice  :radio_choice, [['a', 'Letter A'],
                                ['b', 'Letter B'],
                                ['c', 'Letter C']]
  checkbox_multiple_choice :checkbox_multiple_choice,\
                           [['a', 'Letter A'],
                            ['b', 'Letter B'],
                            ['c', 'Letter C']]
  date          :date, ['%Y-%m-%d']

  def initialize(*args)
    super(*args)
    @error_css_class = 'with-errors'
    @required_css_class = 'required'
  end

  def save
    puts cleaned_data
  end
end

template_path = File.join(File.dirname(__FILE__), 'rackapp1.html')
template = File.open(template_path) do |f|
  ERB.new(f.read)
end

stylesheet_path = File.join(File.dirname(__FILE__), 'style.css')
styles = File.open(stylesheet_path) do |f|
  f.read
end

fields_test_app = lambda do |env|
  req = Rack::Request.new(env)

  unless req.path == '/'
    return [404, {'Content-Type' => 'text', 'Content-Length' => '0'}, '']
  end

  if req.post?
    form = TestForm1.new(req.POST)
  else
    form = TestForm1.new
  end

  result = template.result(binding)

  [200, {'Content-Type' => 'text', 'Content-Length' => result.length.to_s}, [result]]
end

run fields_test_app
