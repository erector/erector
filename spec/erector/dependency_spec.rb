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

    it "is equal to an identical external" do
      x = Erector::Dependency.new(:foo, "abc", {:bar => 7})
      y = Erector::Dependency.new(:foo, "abc", {:bar => 7})
      x.should == y
      [x].should include(y)
    end

    it "is not equal to an otherwise identical external with different options" do
      x = Erector::Dependency.new(:foo, "abc")
      y = Erector::Dependency.new(:foo, "abc", {:bar => 7})
      x.should_not == y
      [x].should_not include(y)
    end

  end
end