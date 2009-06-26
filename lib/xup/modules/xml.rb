module Xup
  module Modules
    module XML
      def tag(tag, contents='', attrs={}, &block)
        contents = build(&block) if block
        "<%s%s>%s</%s>" % [tag, xml_attr(attrs), indent(contents), tag]
      end

      def tag!(tag, contents='', attrs={}, &block)
        concat tag(tag, contents, attrs, &block) + "\n"
      end

      def selfclosing(tag, attrs={})
        "<%s%s />" % [tag, xml_attr(attrs)]
      end

      def selfclosing!(tag, attrs={})
        concat selfclosing(tag, attrs) + "\n"
      end

      def comment(contents='', &block)
        contents = build(:blank, Context, &block) if block
        '<!-- %s -->' % indent(contents)
      end

      def comment!(contents='', &block)
        concat comment(contents, &block)
      end

      def cdata(contents='', &block)
        contents = build(:blank, Context, &block) if block
        '<![CDATA[ %s ]]>' % indent(contents)
      end

      def cdata!(contents='', &block)
        concat cdata(contents, &block)
      end

      def instruct(instruction, attrs={})
        '<?%s %s?>' % [instruction, xml_attr(attrs)]
      end

      def instruct!(instruction, attrs={})
        concat instruct(instruction, attrs)
      end

      private

      def xml_attr(hash)
        return "" if hash.empty?
        hash.collect { |k, v| ' %s="%s"' % [k, v] }.join
      end

      def indent(string)
        return string unless string.index("\n")
        lines = string.split($/).collect do |line|
          " " * (options[:indent] || 2) + line
        end
        "\n#{lines.join($/)}\n"
      end

    end
  end
end
