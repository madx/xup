require 'xup/modules/yaml'

class YAMLContext < Xup::Context
  use Xup::Modules::YAML
  def reset!() @buffer = ""; self; end
end

class CatContext < Xup::Context
  def meow
    "meow"
  end
end

class SampleObject
  yaml_as 'tag:yapok.org,2009:SampleObject'
  attr_accessor :attribute

  def initialize(value)
    @attribute = value
  end
end

describe Xup::Modules::YAML do
  before do
    @context = YAMLContext.new
  end

  should 'require YAML' do
    require('yaml').should.be.false
  end

  describe 'yaml' do
    it 'returns a YAML dump of the given object' do
      @context.yaml([1,2,3]).should == YAML.dump([1,2,3])
      obj = SampleObject.new("value")
      @context.yaml(obj).should == YAML.dump(obj)
    end

    it 'can use other contexts' do
      @context.yaml([1, CatContext.new { meow }.buffer ]).
        should == YAML.dump([1, CatContext.new { meow }.buffer ])
    end

    it 'has a bang version to output to the buffer' do
      @context.yaml!([1,2,3])
      @context.buffer.should == YAML.dump([1,2,3])
    end
  end
end
