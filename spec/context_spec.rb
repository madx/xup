module Cat
  def meow
    @buffer << "meow"
  end
end

describe Xup::Context do

  describe "initialization" do

    before do
      @context = Xup::Context.new(:opt => :value) do
        @buffer << "text"
      end
    end

    it "takes an option hash" do
      @context.options.should == {:opt => :value}
    end

    it "evaluates the given block" do
      @context.buffer.should == "text"
      Xup::Context.new.buffer.should.be.empty
    end

  end # describe initialization

  describe "use" do
    it "adds modules to the current instance" do
      xc = Xup::Context.new do
        use :cat
        meow
      end
      xc.buffer.should == "meow"
    end

    it "is available as a class method" do
      class SubContext < Xup::Context; use :cat end
      sc = SubContext.new do
        meow
      end
      sc.buffer.should == "meow"
    end

    it "prefers top-level modules before searching in Xup::Modules" do
      module Xup::Modules::Cat
        def meow
          concat "woof"
        end
      end
      xc = Xup::Context.new do
        use :cat
        meow
      end
      xc.buffer.should == "meow"
    end
  end # describe use

  describe "concat" do
    it "appends a string to the buffer" do
      xc = Xup::Context.new { concat "text" }
      xc.buffer.should == "text"
      xc.concat "\ntext"
      xc.buffer.should == "text\ntext"
    end

    it "force to a string" do
      xc = Xup::Context.new { concat :text }
      xc.buffer.should == 'text'
    end
  end # describe concat

  describe "build" do
    class CatContext < Xup::Context; use Cat end
    module Dog
      def bark() @buffer << "woof"; end
    end

    it "concats the evaluation of a sub-context" do
      Xup::Context.new {
        concat build { concat "text" }
      }.buffer.should == "text"
    end

    it "handles module propagation" do
      Xup::Context.new {
        use Cat
        concat build { meow }
      }.buffer.should == "meow"

      lambda {
        Xup::Context.new {
          use Cat
          concat build(:blank) { meow }
        }
      }.should.raise NameError, "undefined local variable or method `meow'"
    end

    it "can be passed another kind of context" do
      Xup::Context.new {
        use Dog
        concat build(:inherit, CatContext) { meow; bark}
      }.buffer.should == "meowwoof"

      lambda {
        Xup::Context.new {
          use Dog
          concat build(:blank, CatContext) { meow; bark }
        }
      }.should.raise NameError, "undefined local variable or method `bark'"
    end

    it 'can pass options to the child context' do
      Xup::Context.new {
        concat build(:inherit, self.class, :option => :value) {
          concat options[:option]
        }
      }.buffer.should == "value"
      Xup::Context.new(:option => :value) {
        concat build(:inherit) {
          concat options[:option]
        }
      }.buffer.should == "value"
      Xup::Context.new(:option => :value) {
        concat build(:blank) {
          concat options[:option]
        }
      }.buffer.should == ""
    end
  end # describe build

  describe "build!" do
    it "outputs the result of build to the buffer" do
      Xup::Context.new {
        build! { concat "text" }
      }.buffer.should == "text"
    end
  end
end
