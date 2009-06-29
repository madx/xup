module Xup
  module Modules

    # The XML module provides methods to build XML tags.
    #
    # Methods marked with a bang (!) are used to concat to the buffer with
    # a newline appended.
    #
    # Whenever there is a <tt>contents</tt> and a <tt>block</tt> param, the
    # result of the block evaluation in a new context will be used instead
    # of the contents, unless you don't provide a block.
    #
    # == Options
    #
    # <tt>:indent</tt>:: this option is used to control the amount of
    #                    indentation that you want. The XML modules can only
    #                    indent with spaces.
    #
    # == Example
    #
    #   Xup::Context.new {
    #     use Xup::Modules::XML
    #     tag! :tag, 'contents'
    #     tag! :outer do
    #       tag! :inner, 'contents'
    #     end
    #   }.buffer
    #
    #   <tag>contents</tag>
    #   <outer>
    #     <inner>contents</inner>
    #   </outer>
    module XML

      # Returns a tag built with the given parameters.
      # If you provide both contents and a block, the block is preferred.
      # <tt>attrs</tt> is a hash of XML attributes that will be translated.
      #
      #   tag(:p, 'text') # => <p>text</p>
      #   tag(:p, 'text', :class => "class") # => <p class="class">text</p>
      def tag(tag, contents='', attrs={}, &block)
        contents = build(&block) if block
        "<%s%s>%s</%s>" % [tag, xml_attr(attrs), indent(contents), tag]
      end

      def tag!(tag, contents='', attrs={}, &block)
        concat tag(tag, contents, attrs, &block) + "\n"
      end

      # Returns a self-closing XML tag.
      #
      #   selfclosing(:meta, :attr => "value") # => <meta attr="value" />
      def selfclosing(tag, attrs={})
        "<%s%s />" % [tag, xml_attr(attrs)]
      end

      def selfclosing!(tag, attrs={})
        concat selfclosing(tag, attrs) + "\n"
      end

      # Returns an XML comment.
      #
      #   comment("Hello, world") # => <!-- Hello, world -->
      def comment(contents='', &block)
        contents = build(:blank, Context, &block) if block
        '<!-- %s -->' % indent(contents)
      end

      def comment!(contents='', &block)
        concat comment(contents, &block) + "\n"
      end

      # Returns CDATA contents.
      #
      #   cdata("body { background-color: red }") # =>
      #     <![CDATA[ background-color: red } ]]>
      def cdata(contents='', &block)
        contents = build(:blank, Context, &block) if block
        '<![CDATA[ %s ]]>' % indent(contents)
      end

      def cdata!(contents='', &block)
        concat cdata(contents, &block) + "\n"
      end

      # Returns an XML processing instruction
      #
      #   instruct(:xml, :version => "1.0", :encoding => "UTF-8") # =>
      #     <?xml version="1.0" encoding="UTF-8"?>
      def instruct(instruction, attrs={})
        '<?%s%s?>' % [instruction, xml_attr(attrs)]
      end

      def instruct!(instruction, attrs={})
        concat instruct(instruction, attrs) + "\n"
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
