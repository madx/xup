# coding: utf-8
$KCODE = 'u' if RUBY_VERSION < "1.9"

module Xup

  class Context

    DEFAULTS = {
      :indent => 2
    }

    attr_reader :buffer, :options

    def self.build(&block)
      new.tap {|c| c.instance_eval(&block) }.buffer
    end

    def initialize(options={})
      @buffer = ""
      @options = DEFAULTS.dup.update(options)
    end

    def tag!(tag, contents='', attrs={}, &block)
      contents = Context.build(&block) if block
      "<%s%s>%s</%s>" % [tag, html_attrs(attrs), contents, tag]
    end

    def block!(tag, contents='', attrs={}, &block)
      contents = Context.build(&block) if block
      if contents.index("\n")
        contents = indent(contents)
      end
      @buffer << tag!(tag, contents, attrs) << "\n"
    end

    def inline!(tag, contents='', attrs={}, &block)
      @buffer << tag!(tag, contents, attrs, &block)
    end

    def text(contents)
      @buffer << contents
    end

    # Block tags

    def para(contents='', attrs={}, &block)
      block! :p, contents, attrs, &block
    end
    alias_method :p, :para

    def quote(contents='', attrs={}, &block)
      block! :blockquote, contents, attrs, &block
    end
    alias_method :bq, :quote

    def list(items=[], attrs={}, &block)
      generic_list :ul, items, attrs, &block
    end

    def order(items=[], attrs={}, &block)
      generic_list :ol, items, attrs, &block
    end

    def define(dict={}, attrs={}, &block)
      if block
        block! :dl, nil, attrs, &block
      else
        items = []
        dict.each do |key,value|
          items << tag!(:dt, key)
          value.to_a.each {|val| items << tag!(:dd, val) }
        end
        block! :dl, items.join("\n")
      end
    end

    def li(contents='', attrs={}, &block)
      block! :li, contents, attrs, &block
    end

    # Inline tags
    def a(contents='', url='', attrs={}, &block)
      attrs[:href] = url
      tag! :a, contents, attrs, &block
    end

    %w[em strong del ins code kbd sup sub].each do |meth|
      class_eval %Q{
        def #{meth}(contents='', attrs={}, &block)
          tag! :#{meth}, contents, attrs, &block
        end
      }
    end

    private

    def html_attrs(attributes)
      return "" if attributes.empty?
      attributes.collect { |k, v|
        v = v.join(' ') if v.kind_of? Array
        ' %s="%s"' % [k, v]
      }.join
    end

    def generic_list(tag, items=[], attrs={}, &block)
      if block
        block! tag, nil, attrs, &block
      else
        contents = items.collect {|i| tag! :li, i}.join("\n")
        block! tag, contents, attrs, &block
      end
    end

    def indent(string)
      "\n#{string.split($/).collect {|l| " " * @options[:indent] + l }.join($/)}\n"
    end

    def format(type)
    end
  end
end
