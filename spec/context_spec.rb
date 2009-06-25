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
        use Cat
        meow
      end
      xc.buffer.should == "meow"
    end

    it "is available as a class method" do
      class SubContext < Xup::Context; use Cat end
      sc = SubContext.new do
        meow
      end
      sc.buffer.should == "meow"
    end
  end # describe use

  describe "concat" do
    it "appends a string to the buffer" do
      xc = Xup::Context.new { concat "text" }
      xc.buffer.should == "text"
      xc.concat "\ntext"
      xc.buffer.should == "text\ntext"
    end
  end # describe concat

  describe "build methods" do
    class CatContext < Xup::Context; use Cat end
    module Dog
      def bark() @buffer << "woof"; end
    end

    describe "-> build" do
      it "concats the evaluation of a sub-context" do
        Xup::Context.new {
          build { concat "text" }
        }.buffer.should == "text"
      end

      it "propagates included modules" do
        Xup::Context.new {
          use Cat
          build { meow }
        }.buffer.should == "meow"
      end

      it "can be passed another kind of context" do
        Xup::Context.new {
          use Dog
          build(CatContext) { meow; bark}
        }.buffer.should == "meowwoof"
      end
    end # describe build

    describe "-> build!" do
      it "does the same things as build without propagating modules" do
        Xup::Context.new {
          build! { concat "text" }
        }.buffer.should == "text"

        lambda {
          Xup::Context.new {
            use Cat
            build! { meow }
          }
        }.should.raise NameError, "undefined local variable or method `meow'"

        lambda {
          Xup::Context.new {
            use Dog
            build!(CatContext) { meow; bark }
          }
        }.should.raise NameError, "undefined local variable or method `bark'"
      end
    end # describe build!
  end # describe build methods

end
