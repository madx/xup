describe Xup::Context do

  before do
    def build(&blk)
      @context.instance_eval &blk
    end

    def buffer
      @context.buffer
    end

    @context = Xup::Context.new
  end

  describe "== Initialization" do
    it "creates a read-only empty buffer" do
      @context.buffer.should.be.empty
      lambda { @context.buffer = "foo" }.should.raise NoMethodError
    end

    it "provides default options" do
      @context.options.should == Xup::Context::DEFAULTS
    end
  end

  describe "== Underlying methods" do
    describe ".tag!" do
      it "returns a string with the corresponding.tag!" do
        @context.tag!(:em, "word").should == "<em>word</em>"
      end

      it "returns an empty tag when contents are empty" do
        @context.tag!(:em).should == '<em></em>'
      end

      it "transorms the attributes hash to HTML attributes" do
        @context.tag!(:a, 'link', :href => 'http://somesite.com').
          should == '<a href="http://somesite.com">link</a>'
      end

      it "makes a nested tag when given a block" do
        @context.tag!(:p) { @buffer << tag!(:em, 'word') }.
          should == "<p><em>word</em></p>"
      end
    end

    describe "#block!" do
      it 'acts as inline! when there is a single line' do
        build { block! :p, "paragraph"}
        buffer.should == "<p>paragraph</p>\n"
      end

      it "indents the contents when a block is given" do
        build { block!(:p) { text "a\nparagraph" } }
        buffer.should == "<p>\n  a\n  paragraph\n</p>\n"
      end
    end

    describe "#text" do
      it "outputs given contents in the buffer" do
        build { text "foo" }
        buffer.should == "foo"
      end
    end
  end

  describe "== Block tags" do

    describe "para (paragraph, <p>)" do
      it "outputs a block paragraph in the buffer" do
        build { para "paragraph" }
        buffer.should == "<p>paragraph</p>\n"
      end

      it "supports nesting" do
        build { para { text "nested text" } }
        buffer.should == "<p>nested text</p>\n"
      end

      it "should be callable as p" do
        @context.para("paragraph").should == @context.p("paragraph")
      end
    end

    describe "quote (block quotation, <blockquote>)" do
      it "outputs a block quotation in the buffer" do
        build { quote "Xup rocks!" }
        buffer.should == "<blockquote>Xup rocks!</blockquote>\n"
      end

      it "supports nesting" do
        build { quote { text "Xup rocks!\n"; inline! :cite, 'me' } }
        buffer.should == %Q{
          <blockquote>\n  Xup rocks!\n  <cite>me</cite>\n</blockquote>
        }.strip << "\n"
      end

      it "should be callable as bq" do
        @context.bq("quote").should == @context.quote("quote")
      end
    end

    describe "list (unordered list, <ul>)" do
      it "outputs an unordered list of elements in the buffer" do
        build { list %w[one two] }
        buffer.should == "<ul>\n  <li>one</li>\n  <li>two</li>\n</ul>\n"
      end

      it "supports nesting" do
        build {
          list {
            inline! :li, 'one'
            text "\n"
            inline! :li, 'two'
          }
        }
        buffer.should == "<ul>\n  <li>one</li>\n  <li>two</li>\n</ul>\n"
      end
    end

    describe "order (ordred list, <ol>)" do
      it "works like list() but with an ordered list" do
        build {
          order %w[one two]
          order {
            inline! :li, 'one'
            text "\n"
            inline! :li, 'two'
          }
        }
        buffer.should == "<ol>\n  <li>one</li>\n  <li>two</li>\n</ol>\n" +
                         "<ol>\n  <li>one</li>\n  <li>two</li>\n</ol>\n"
      end
    end

    describe "define (definition list, <dl>)" do
      it "takes an hash an outputs a definition list in the buffer" do
        build { define "word" => "a unit of language" }
        buffer.should ==
          "<dl>\n  <dt>word</dt>\n  <dd>a unit of language</dd>\n</dl>\n"
      end

      it "supports nesting" do
        build {
          define {
            inline! :dt, "word"
            text "\n"
            inline! :dd, "a unit of language"
          }
        }
        buffer.should ==
          "<dl>\n  <dt>word</dt>\n  <dd>a unit of language</dd>\n</dl>\n"
      end
    end
  end
end
