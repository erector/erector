require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")
require 'benchmark'
require 'active_support' # for Symbol#to_proc

module DependencySpec
  describe Erector::Dependency do
    it "can be constructed with type and text" do
      x = Erector::Dependency.new(:foo, "abc")
      x.type.should == :foo
      x.text.should == "abc"
      x.options.should == {}
    end

    it "can be constructed with type, text, and options" do
      x = Erector::Dependency.new(:foo, "abc", {:bar => 7})
      x.options.should == {:bar => 7}
    end

    it "can be constructed with a file" do
      file = File.new("#{File.dirname(__FILE__)}/sample-file.txt")
      x = Erector::Dependency.new(:foo, file)
      x.text.should == "sample file contents, 2 + 2 = \#{2 + 2}\n"
    end

    it "can be constructed with a file and interpolate the text" do
      file = File.new("#{File.dirname(__FILE__)}/sample-file.txt")
      x = Erector::Dependency.new(:foo, file, :interpolate => true)
      x.text.should == "sample file contents, 2 + 2 = 4\n"
    end

    describe "comparison methods" do
      before do
        @castor = Erector::Dependency.new(:foo, "abc", {:bar => 7})
        @pollux = Erector::Dependency.new(:foo, "abc", {:bar => 7})
        @leo = Erector::Dependency.new(:foo, "abc")
        @pisces = Erector::Dependency.new(:foo, "xyz", {:bar => 7})
      end

      it "is equal to an identical external" do
        @castor.should == @pollux
        [@castor].should include(@pollux)
        @castor.eql?(@pollux).should be_true
        @castor.hash.should == @pollux.hash
      end

      it "is not equal to an otherwise identical external with different options" do
        @castor.should_not == @leo
        [@castor].should_not include(@leo)
        @castor.eql?(@leo).should_not be_true
        @castor.hash.should_not == @leo.hash
      end

      it "is not equal to a different external with the same options" do
        @castor.should_not == @pisces
        [@castor].should_not include(@pisces)
        @castor.eql?(@pisces).should_not be_true
        @castor.hash.should_not == @pisces.hash
      end

      # see http://blog.nathanielbibler.com/post/73525836/using-the-ruby-array-uniq-with-custom-classes
      it "works with uniq" do
        [@castor, @pollux, @leo].uniq.should == [@castor, @leo]
      end

    end
  end
end
