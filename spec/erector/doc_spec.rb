require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

module Erector
  describe Doc do
    describe "#output" do
      it "seeks to the end of the buffer" do
        string = "Hello"
        widget = Widget.new(nil, {}, string)
        doc = Doc.new(widget)

        string.concat(" World")
        doc.text " Again"

        string.should == "Hello World Again"
      end
    end

    describe "#method_missing" do
      context "when passed in io object raises a NoMethodError" do
        context "when the passed in io object respond_to? method is false" do
          attr_reader :string
          before do
            @string = ""
            string.should_not respond_to(:foo)
            lambda {string.foo}.should raise_error(NoMethodError, /undefined method `foo' for "":String/)
          end

          it "raises a NoMethodError that originates from within Doc#method_missing" do
            widget = Widget.new
            string = widget.output
            doc = Doc.new(string)
            lambda do
              doc.foo
            end.should raise_error(NoMethodError, /undefined method `foo' for #<Erector::Doc/)
          end
        end

        context "when the passed in string object respond_to? method is true" do
          attr_reader :string
          before do
            @string = ""
            stub(string).foo {raise NoMethodError, "Stubbed NoMethodError"}
            string.should respond_to(:foo)
            lambda {string.foo}.should raise_error(NoMethodError, "Stubbed NoMethodError")
          end

          it "raises a NoMethodError that originates from within Doc#method_missing" do
            widget = Widget.new
            string = widget.output
            doc = Doc.new(string)
            lambda do
              doc.foo
            end.should raise_error(NoMethodError, /undefined method `foo' for #<Erector::Doc/)
          end
        end
      end
    end
  end
end
