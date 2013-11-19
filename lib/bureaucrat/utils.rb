module Bureaucrat
  module Utils
    extend self

    module SafeData
    end

    class SafeString < String
      include SafeData

      def to_s
        SafeString.new(self)
      end

      def +(rhs)
        rhs.is_a?(SafeString) ? SafeString.new(super(rhs)) : super(rhs)
      end
    end

    class StringAccessHash < Hash
      def initialize(other = {})
        super()
        update(other)
      end

      def []=(key, value)
        if value.respond_to? :gsub
          value = Utils.escape(value)
        end
        super(key.to_s, value)
      end

      def [](key)
        super(key.to_s)
      end

      def fetch(key, *args)
        super(key.to_s, *args)
      end

      def include?(key)
        super(key.to_s)
      end

      def update(other)
        other.each_pair{|k, v| self[k] = v}
        self
      end

      def merge(other)
        dup.update(other)
      end

      def delete(key)
        super(key.to_s)
      end
    end

    def blank_value?(value)
      !value || value == ''
    end

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

    def make_float(value)
      value += '0' if value.is_a?(String) && value != '.' && value[-1,1] == '.'
      Float(value)
    end

    def make_bool(value)
      !(value.respond_to?(:empty?) ? value.empty? : [0, nil, false].include?(value))
    end

  end
end
