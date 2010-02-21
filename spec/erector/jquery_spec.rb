require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe Erector::JQuery do
  describe "#jquery" do
    it "outputs the appropriate script block" do
      Erector.inline { jquery "alert('hello');" }.to_s.should =~ /#{Regexp.escape("jQuery(document).ready(function($){\nalert('hello');\n});")}/
    end
  end
end
