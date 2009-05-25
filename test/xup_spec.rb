require 'bacon'
require 'xup'

class Fixture
  attr_reader :in, :out

  def initialize(hash)
    @in, @out = hash[:in], hash[:out]
  end

  def should_translate_properly
    Xup.new(@in).to_html.should == @out
  end

  def self.open
    file = File.join(File.dirname(__FILE__), 'fixtures.yml')
    YAML.load(File.read(file)).tap { |hash|
      hash.map {|key, val| hash[key] = new(val) }
    }
  end
end

describe Xup do

  @fixtures = Fixture.open

  def fixture(key)
    @fixtures[key]
  end

  should "have basic paragraphs" do
    fixture(:basic_para).should_translate_properly
  end

  should "have multiline paragraphs" do
    fixture(:multiline_para).should_translate_properly
  end

  should "have headers" do
    fixture(:headers).should_translate_properly
  end

  should "have unordered lists" do
    fixture(:unordered_lists).should_translate_properly
  end

  should "have ordered lists" do
    fixture(:ordered_lists).should_translate_properly
  end

end
