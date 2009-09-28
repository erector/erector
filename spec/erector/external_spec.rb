require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")
require 'benchmark'

describe "external declarations" do
  class HotSauce < Erector::Widget
    external "css", "/css/tapatio.css"
    external "css", "/css/salsa_picante.css"
    external "js", "/lib/jquery.js"
    external "js", "/lib/picante.js"
  end
  
  class SourCream < Erector::Widget
    external "css", "/css/sourcream.css"
    external "js", "/lib/jquery.js"
    external "js", "/lib/dairy.js"
  end
  
  it "can be fetched via the type" do
    Erector::Widget.externals("css").should == [
      "/css/tapatio.css",
      "/css/salsa_picante.css",
      "/css/sourcream.css",
      ]
  end
  
  it "can be filtered via the class" do
    Erector::Widget.externals("css", HotSauce).should == [
      "/css/tapatio.css",
      "/css/salsa_picante.css",
      ]
    Erector::Widget.externals("css", SourCream).should == [
      "/css/sourcream.css",
      ]
  end
  
  it "removes duplicates" do
    Erector::Widget.externals("js").should == [
      "/lib/jquery.js",
      "/lib/picante.js",
      "/lib/dairy.js",
      ]
  end

end
