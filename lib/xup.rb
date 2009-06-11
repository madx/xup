# coding: utf-8
$KCODE = 'u' if RUBY_VERSION < "1.9"

module Xup

  class Context

    DEFAULTS = {
      :indent => 2
    }

    attr_reader :buffer, :options

    def initialize(options={})
      @buffer = ""
      @options = DEFAULTS.dup.update(options)
    end

    def clear!
      @buffer = ""
    end

    def block(tag, contents, attrs={})
      "<%s%s>%s</%s>\n\n" % [tag, html_attr(attrs), indent(contents), tag]
    end

    def inline(tag, contents, attrs={})
      "<%s%s>%s</%s>" % [tag, attrs, contents, tag]
    end

    def block!(tag, contents, attrs={})
      @buffer << block(tag, contents, attrs)
    end

    def inline!(tag, contents, attrs={})
      @buffer << inline(tag, contents, attrs)
    end


    def para(contents, attrs={})
      contents = contents.join("<br />\n") if contents.kind_of? Array
      block! :p, contents, attrs
    end

    def quote(contents, attrs={})
      contents = contents.join("<br />\n") if contents.kind_of? Array
      block! :blockquote, contents, attrs
    end

    def list(contents, attrs={})
      contents = contents.collect {|item| inline(:li, item) }.join($/)
      block! :ul, contents, attrs
    end

    def order(contents, attrs={})
      contents = contents.collect {|item| inline(:li, item) }.join($/)
      block! :ol, contents, attrs
    end

    def define(contents, attrs={})
      tags = []
      contents.each do |key, value|
        tags << inline(:dt, key)
        if value.kind_of? Array
          value.each {|v| tags << inline(:dd, v) }
        else
          tags << inline(:dd, value)
        end
      end
      block! :dl, tags.join($/), attrs
    end

    private

    def html_attr(attributes)
      return "" if attributes.empty?
      attributes.collect { |k, v|
        v = v.join(' ') if v.kind_of? Array
        ' %s="%s"' % [k, v]
      }.join
    end

    def indent(string)
      "\n#{string.split($/).collect {|l| " " * @options[:indent] + l }.join($/)}\n"
    end
  end
end
