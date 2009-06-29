describe Xup do
  describe ".load_module" do
    it 'requires a module inside lib/xup/modules' do
      Xup.const_defined?(:Modules).should.be.true
      Xup::Modules.const_defined?(:YAML).should.be.false
      Xup.load :yaml
      Xup::Modules.const_defined?(:YAML).should.be.true
    end

    it 'can load multiple modules at once' do
      Xup.const_defined?(:Modules).should.be.true
      Xup::Modules.const_defined?(:YAML).should.be.true # side effect from
                                                        # previous test
      Xup::Modules.const_defined?(:XML) .should.be.false
      Xup.load :yaml, :xml
      Xup::Modules.const_defined?(:YAML).should.be.true
      Xup::Modules.const_defined?(:XML) .should.be.true
    end
  end
end
