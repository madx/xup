require 'xup/modules/xml'

class XMLContext < Xup::Context
  use Xup::Modules::XML
end

describe Xup::Modules::XML do
  before do
    @context = XMLContext.new
  end

  describe 'tag' do
    it 'returns an XML tag with the contents enclosed' do
      @context.tag(:tag, 'text').should == '<tag>text</tag>'
    end

    it 'transforms the attribute hash to XML attributes' do
      @context.tag(:tag, '', :attribute => 'value').
        should == '<tag attribute="value"></tag>'
    end

    it 'indents the contents if there are multiple lines' do
      @context.tag(:tag, "text\ntext").
        should == "<tag>\n  text\n  text\n</tag>"
    end

    it 'uses the indent option' do
      @context.options[:indent] = 4
      @context.tag(:tag, "text\ntext").
        should == "<tag>\n    text\n    text\n</tag>"
    end

    it 'uses the output of the block to build the contents' do
      @context.tag(:outer) { concat tag(:inner) }.
        should == '<outer><inner></inner></outer>'
    end

    it 'has a bang version to output to the buffer' do
      @context.tag! :tag, 'text'
      @context.buffer.should == "<tag>text</tag>\n"
    end
  end

  describe 'selfclosing' do
    it 'returns an XML self-closing tag' do
      @context.selfclosing(:tag).should == '<tag />'
      @context.selfclosing(:tag, :attribute => 'value').
        should == '<tag attribute="value" />'
    end

    it 'has a bang version to output to the buffer' do
      @context.selfclosing!(:tag)
      @context.buffer.should == "<tag />\n"
    end
  end

  describe 'instruct' do
    it 'returns an xml processing instruction' do
      @context.instruct(:xml, :version => "1.0", :encoding => "UTF-8").
        should =~ /^<\?xml /
      @context.instruct(:xml, :version => "1.0", :encoding => "UTF-8").
        should.include 'encoding="UTF-8"'
      @context.instruct(:xml, :version => "1.0", :encoding => "UTF-8").
        should.include 'version="1.0"'
      @context.instruct(:xml, :version => "1.0", :encoding => "UTF-8").
        should =~ /\?>$/
    end

    it 'has a bang version to output to the buffer' do
      @context.instruct!(:xml, :version => "1.0", :encoding => "UTF-8")
      @context.buffer.should =~ /^<\?xml /
    end
  end

  describe 'comment' do
    it 'returns an XML comment' do
      @context.comment('text').should == '<!-- text -->'
      @context.comment("text\ntext").
        should == "<!-- \n  text\n  text\n -->"
      @context.comment {
        concat 'text'
      }.should == '<!-- text -->'
    end

    it 'should not propagate modules when called with a block' do
      lambda {
        @context.comment {
          tag! :tag
        }
      }.should.raise NoMethodError
    end

    it 'has a bang version to output to the buffer' do
      @context.comment! 'text'
      @context.buffer.should == "<!-- text -->\n"
    end
  end

  describe 'cdata' do
    it 'returns an XML CDATA' do
      @context.cdata('text').should == '<![CDATA[ text ]]>'
      @context.cdata("text\ntext").
        should == "<![CDATA[ \n  text\n  text\n ]]>"
      @context.cdata {
        concat 'text'
      }.should == '<![CDATA[ text ]]>'
    end

    it 'should not propagate modules when called with a block' do
      lambda {
        @context.cdata {
          tag! :tag
        }
      }.should.raise NoMethodError
    end

    it 'has a bang version to output to the buffer' do
      @context.cdata! 'text'
      @context.buffer.should == "<![CDATA[ text ]]>\n"
    end
  end
end
