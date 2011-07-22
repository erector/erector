require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")
require "erector/tag"

module Erector
  describe Tag do
    it "takes a name" do
      t = Tag.new("foo")
      t.name.should == "foo"
    end

    it "has default values for its options" do
      t = Tag.new("foo")
      t.self_closing?.should == false
      t.inline?.should == false
    end

    it "can take any combination of options" do
      t = Tag.new("foo", :self_closing)
      t.self_closing?.should == true
      t.inline?.should == false

      t = Tag.new("foo", :inline)
      t.self_closing?.should == false
      t.inline?.should == true

      t = Tag.new("foo", :self_closing, :inline)
      t.self_closing?.should == true
      t.inline?.should == true

      t = Tag.new("foo", :inline, :self_closing)
      t.self_closing?.should == true
      t.inline?.should == true
    end

    it "can take a method name" do
      t = Tag.new("foo", "bar")
      t.name.should == "foo"
      t.method_name.should == "bar"
      t.self_closing?.should == false
      t.inline?.should == false
    end

    it "can take a method name and options" do
      t = Tag.new("foo", "bar", :self_closing, :inline)
      t.name.should == "foo"
      t.method_name.should == "bar"
      t.self_closing?.should == true
      t.inline?.should == true
    end

    it "can underscorize its method name" do
      t = Tag.new("InclusiveLowerBound", :snake_case)
      t.name.should == "InclusiveLowerBound"
      t.method_name.should == "inclusive_lower_bound"
    end

    it "is smart about acronyms" do
      t = Tag.new("WatchCNNToday", :snake_case)
      t.name.should == "WatchCNNToday"
      t.method_name.should == "watch_cnn_today"
    end


  end
end


