require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")
require 'benchmark'

describe "passing in a block" do
  describe Erector::Widget do
    it "'s block is evaluated in the calling object's context" do
      
      @sample_instance_variable = "yum"
      sample_bound_variable = "yay"
      Erector::Widget.new do
        @sample_instance_variable.should == "yum"
        sample_bound_variable.should == "yay"
        lambda {text "you can't call Erector methods from in here"}.should raise_error(NoMethodError)
        # puts "uncomment this to prove this is being executed"
      end.to_s
      
    end
  end

  describe Erector::Inline do
    it "'s block is evaluated in the widget's context" do
      
      @sample_instance_variable = "yum"
      sample_bound_variable = "yay"
      Erector.inline do
        @sample_instance_variable.should be_nil
        sample_bound_variable.should == "yay"
        text "you can call Erector methods from in here"
        # puts "uncomment this to prove this is being executed"
      end.to_s
      
    end
  end
  
  describe Erector::Mixin do
    include Erector::Mixin
    it "'s block is evaluated in the parent widget's context" do
      
      @sample_instance_variable = "yum"
      sample_bound_variable = "yay"
      erector do
        @sample_instance_variable.should be_nil
        sample_bound_variable.should == "yay"
        text "you can call Erector methods from in here"
        # puts "uncomment this to prove this is being executed"
      end
      
    end
  end
    
end
