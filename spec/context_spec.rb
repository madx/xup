require File.join(File.dirname(__FILE__), 'helper')


describe Xup::Context do

  before do
    @context = Xup::Context.new

    def build(&blk)
      @context.instance_eval &blk
    end

    def buffer
      @context.buffer
    end
  end

  describe "initialization" do
    should "create a read-only empty buffer" do
      @context.buffer.should.be.empty
      lambda { @context.buffer = "foo" }.should.raise NoMethodError
    end

    should "have options" do
      @context.options.should == Xup::Context::DEFAULTS
    end
  end

  describe "#block!" do
    should "append a block tag in the buffer" do
      build { block! :p, "foo bar" }
      buffer.should == "<p>\n  foo bar\n</p>\n\n"
    end

    should "transform the attrs param into an HTML attribute list" do
      build { block! :p, "foo", :attr => "value" }
      buffer.should == %Q{<p attr="value">\n  foo\n</p>\n\n}
    end

    should "build a string if an attribute is passed an array" do
      build { block! :p, "foo", :attr => %w[value1 value2] }
      buffer.should == %Q{<p attr="value1 value2">\n  foo\n</p>\n\n}
    end
  end

  describe "#clear!" do
    should "create a new buffer" do
      build { para "foo" }
      buffer.should.not.be.empty
      @context.clear!
      buffer.should.be.empty
    end
  end

  describe "#para" do
    should "build a paragraph" do
      build { para "foo" }
      buffer.should == "<p>\n  foo\n</p>\n\n"
    end

    should "use line breaks if given an array" do
      build { para %w[one two] }
      buffer.should == "<p>\n  one<br />\n  two\n</p>\n\n"
    end
  end

  describe "#quote" do
    should "build a blockquote based on a string" do
      build { quote "foo" }
      buffer.should == "<blockquote>\n  foo\n</blockquote>\n\n"
    end
  end

  describe "#list" do
    should "build an unordered list based on an array" do
      build { list %w[one two three] }
      buffer.should == <<out
<ul>
  <li>one</li>
  <li>two</li>
  <li>three</li>
</ul>

out
    end
  end

  describe "#order" do
    should "build an ordered list based on an array" do
      build { order %w[one two three] }
      buffer.should == <<out
<ol>
  <li>one</li>
  <li>two</li>
  <li>three</li>
</ol>

out
    end
  end

  describe "#define" do
    should "build a definition list based on a hash" do
      build { define "foo" => "bar" }
      buffer.should == <<out
<dl>
  <dt>foo</dt>
  <dd>bar</dd>
</dl>

out
    end

    should "have multiple definitions when a value is an array" do
      build { define "foo" => %w[bar baz] }
      buffer.should == <<out
<dl>
  <dt>foo</dt>
  <dd>bar</dd>
  <dd>baz</dd>
</dl>

out
    end
  end

end
