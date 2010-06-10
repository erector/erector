require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe Erector::JQuery do
  include Erector::Mixin

  describe "#jquery" do
    it "outputs the appropriate script block" do
      erector { jquery "alert('hello');" }.should =~ /#{Regexp.escape("jQuery(document).ready(function($){\nalert('hello');\n});")}/
    end
  end
end
