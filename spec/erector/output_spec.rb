require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

module Erector
  describe Erector::Output do
    before do
      @output = Output.new
    end

    it "accepts a string via the << operator" do
      @output.to_s.should == ""
      @output << "foo"
      @output.to_s.should == "foo"
      @output << "bar"
      @output.to_s.should == "foobar"
    end

    it "#<< accepts a number" do
      @output << 1
      @output.to_s.should == "1"
    end

    it "accepts chained <<s" do
      @output << "foo" << "bar"
      @output.to_s.should == "foobar"
    end

    it "provides a placeholder string to be filled in later" do
      @output << "foo"
      placeholder = @output.placeholder
      @output << "bar"
      @output.to_s.should == "foobar"
      placeholder << "baz"
      @output.to_s.should == "foobazbar"
    end

    describe '#to_a' do
      it "emits an array" do
        @output << "foo" << "bar"
        @output.to_a.join.should == "foobar"
      end
    end

    it "can be initialized with an existing string buffer" do
      s = "foo"
      @output = Output.new { s }
      @output << "bar"
      s.should == "foobar"
      @output.to_s.should == "foobar"
    end

    it "accepts a prettyprint option" do
      Erector::Output.new(:prettyprint => true).prettyprint.should be_true
      Erector::Output.new(:prettyprint => false).prettyprint.should be_false
    end

    it "accepts the global prettyprint_default setting" do
      old_default = Erector::Widget.new.prettyprint_default
      begin
        Erector::Widget.prettyprint_default = true
        Erector::Output.new.prettyprint.should be_true
        Erector::Widget.prettyprint_default = false
        Erector::Output.new.prettyprint.should be_false
      ensure
        Erector::Widget.prettyprint_default = old_default
      end
    end

    describe '#newline' do
      it "inserts a newline if we're in prettyprint mode" do
        @output = Output.new(:prettyprint => true)
        @output << "foo"
        @output.newline
        @output.should be_at_line_start
        @output.to_s.should == "foo\n"
      end

      it "tracks whether we're at the beginning of a line or not" do
        @output = Output.new(:prettyprint => true)
        @output.should be_at_line_start
        @output << "foo"
        @output.should_not be_at_line_start
        @output.newline
        @output.should be_at_line_start
        @output << "bar"
        @output.should_not be_at_line_start
        @output.newline
        @output.should be_at_line_start
      end

      it "doesn't insert a newline (or track line starts) if we're not in prettyprint mode" do
        @output = Output.new(:prettyprint => false)
        @output << "foo"
        @output.newline
        @output.should_not be_at_line_start
        @output.to_s.should == "foo"
      end
    end

    describe "pretty printing" do
      before do
        @output = Output.new(:prettyprint => true)
      end

      it "indents the next line when we're at line start and indented" do
        @output << "foo"
        @output.newline
        @output.indent
        @output << "bar"
        @output.newline
        @output.undent
        @output << "baz"
        @output.newline

        @output.to_s.should == "foo\n  bar\nbaz\n"
      end

      it "doesn't indent if there's a linebreak in the middle of a string" do
        @output.indent
        @output << "foo\nbar\nbaz\n"
        @output.to_s.should == "  foo\nbar\nbaz\n"
      end

      it "turns off if prettyprint is false" do
        @output = Output.new(:prettyprint => false)
        @output.indent
        @output << "bar"
        @output.to_s.should == "bar"
      end

      it "doesn't crash if indentation level is less than 0" do
        @output.undent
        @output << "bar"
        @output.to_s.should == "bar"
        # [@indentation, 0].max
      end

      it "accepts an initial indentation level" do
        @output = Output.new(:prettyprint => true, :indentation => 2)
        @output << "foo"
        @output.to_s.should == "    foo"
      end

      it "accepts a max line length" do
        @output = Output.new(:prettyprint => true, :max_length => 10)
        @output << "Now is the winter of our discontent made "
        @output << "glorious summer by this sun of York."
        @output.to_s.should ==
                        "Now is the\n" +
                        "winter of\n" +
                        "our\n" +
                        "discontent\n" +
                        "made \n" +
                        "glorious\n" +
                        "summer by\n" +
                        "this sun\n" +
                        "of York."
      end

      it "preserves leading and trailing spaces" do
        @output = Output.new(:max_length => 10)
        @output << "123456789"
        @output << " foo "
        @output << "bar"
        @output.to_s.should == "123456789 \nfoo bar"
      end

      it "accepts a max line length wth indentation" do
        # note that 1 indent = 2 spaces
        @output = Output.new(:prettyprint => true, :indentation => 1, :max_length => 10)
        @output << "Now is the winter of our discontent made glorious summer by this sun of York."
        @output.to_s.should ==
                        "  Now is\n" +
                        "  the\n" +
                        "  winter\n" +
                        "  of our\n" +
                        "  discontent\n" +
                        "  made\n" +
                        "  glorious\n" +
                        "  summer\n" +
                        "  by this\n" +
                        "  sun of\n" +
                        "  York."
      end

    end

    class Puppy < Erector::Widget
    end
    class Kitten < Erector::Widget
    end

    it "can keep track of widget classes emitted to it" do
      @output.widgets << Puppy
      @output.widgets << Kitten
      @output.widgets << Puppy
      @output.widgets.to_a.should include_only([Puppy, Kitten])
    end
  end
end
