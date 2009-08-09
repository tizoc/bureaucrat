module Bureaucrat
module Utils

  module SafeData
  end

  class SafeString < String
    include SafeData

    def +(rhs)
      rhs.is_a?(SafeString) ? SafeString.new(super(rhs)) : super(rhs)
    end
  end

  # Dumb implementation that is good enough for Forms
  class OrderedHash < Hash
    def initialize
      super()
      @ordered_keys = []
    end

    def []=(key, value)
      super(key, value)
      @ordered_keys << key unless @ordered_keys.include?(key)
    end

    def each
      @ordered_keys.each do |key|
          yield key, self[key]
        end
    end

    def initialize_copy(original)
      super(original)
      @ordered_keys = original.instance_eval('@ordered_keys').dup
    end
  end

module_function

  def mark_safe(s)
    s.is_a?(SafeData) ? s : SafeString.new(s.to_s)
  end

  ESCAPES = {
    '&' => '&amp;',
    '<' => '&lt;',
    '>' => '&gt;',
    '"' => '&quot;',
    "'" => '&#39;'
  }
  def escape(html)
    mark_safe(html.gsub(/[&<>"']/) {|match| ESCAPES[match]})
  end

  def conditional_escape(html)
    html.is_a?(SafeData) ? html : escape(html)
  end

  def flatatt(attrs)
    attrs.map {|k, v| " #{k}=\"#{conditional_escape(v)}\""}.join('')
  end

  def format_string(string, values)
    output = string.dup
    values.each_pair do |variable, value|
        output.gsub!(/%\(#{variable}\)s/, value.to_s)
      end
    output
  end

  def pretty_name(name)
    name.to_s.capitalize.gsub!(/_/, ' ')
  end

  def make_float(value)
    value += '0' if value.is_a?(String) && value != '.' && value[-1,1] == '.'
    Float(value)
  end

  def make_bool(value)
    !(value.respond_to?(:empty?) ? value.empty? : [0, nil, false].include?(value))
  end
end; end
