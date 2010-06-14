require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe Erector::JQuery do
  include Erector::Mixin

  describe "#jquery" do
    it "outputs a 'jquery ready' script block by default" do
      erector { jquery "alert('hello');" }.should =~ /#{Regexp.escape("jQuery(document).ready(function($){\nalert('hello');\n});")}/
    end

    it "outputs a 'jquery ready' script block" do
      erector { jquery :ready, "alert('hello');" }.should =~ /#{Regexp.escape("jQuery(document).ready(function($){\nalert('hello');\n});")}/
    end

    it "outputs a 'jquery load' script block" do
      erector { jquery :load, "alert('hello');" }.should =~ /#{Regexp.escape("jQuery(document).load(function($){\nalert('hello');\n});")}/
    end
  end
end
