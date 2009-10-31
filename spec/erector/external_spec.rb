require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")
require 'benchmark'
require 'active_support' # for Symbol#to_proc

describe Erector::External do
  it "can be constructed with type, klass, text" do
    x = Erector::External.new(:foo, Object, "abc")
    x.type.should == :foo
    x.klass.should == Object
    x.text.should == "abc"
    x.options.should == {}
  end

  it "can be constructed with type, klass, text, and options" do
    x = Erector::External.new(:foo, Object, "abc", {:bar => 7})
    x.options.should == {:bar => 7}
  end
  
  it "is equal to an identical external" do
    x = Erector::External.new(:foo, Object, "abc", {:bar => 7})
    y = Erector::External.new(:foo, Object, "abc", {:bar => 7})
    x.should == y
    [x].should include(y)
  end
  
  it "is equal to an identical external with a different class" do
    class_x = Class.new
    class_y = Class.new
    x = Erector::External.new(:foo, class_x, "abc", {:bar => 7})
    y = Erector::External.new(:foo, class_y, "abc", {:bar => 7})
    x.should == y
    [x].should include(y)
  end
  
  it "is not equal to an identical external with a different options" do
    class_x = Class.new
    x = Erector::External.new(:foo, class_x, "abc")
    y = Erector::External.new(:foo, class_x, "abc", {:bar => 7})
    x.should_not == y
    [x].should_not include(y)
  end
  
end

describe "external declarations" do
  class HotSauce < Erector::Widget
    external :css, "/css/tapatio.css", :media => "print"
    external :css, "/css/salsa_picante.css"
    external :js, "/lib/jquery.js"
    external :js, "/lib/picante.js"
  end
  
  class SourCream < Erector::Widget
    external :css, "/css/sourcream.css"
    external :js, "/lib/jquery.js"
    external :js, "/lib/dairy.js"
  end
  
  it "can be fetched via the type" do
    Erector::Widget.externals(:css).map(&:text).should == [
      "/css/tapatio.css",
      "/css/salsa_picante.css",
      "/css/sourcream.css",
      ]
  end
  
  it "can be filtered via the class" do
    Erector::Widget.externals(:css, HotSauce).map(&:text).should == [
      "/css/tapatio.css",
      "/css/salsa_picante.css",
      ]
    Erector::Widget.externals(:css, SourCream).map(&:text).should == [
      "/css/sourcream.css",
      ]
  end
  
  it "retains the options" do
    Erector::Widget.externals(:css, HotSauce).map(&:options).should == [
      {:media => "print"}, 
      {}
    ]
  end
  
  it "removes duplicates" do
    Erector::Widget.externals(:js).map(&:text).should == [
      "/lib/jquery.js",
      "/lib/picante.js",
      "/lib/dairy.js",
      ]
  end


  class Taco < Erector::Widget
    external :filling, "beef"
    external :filling, "beef", :media => "print"
  end
    
  it "considers options when removing duplicates" do
    Erector::Widget.externals(:filling).map(&:text).should == ["beef", "beef"]
  end
  
  it "works with strings or symbols" do
    Erector::Widget.externals("js").map(&:text).should == [
      "/lib/jquery.js",
      "/lib/picante.js",
      "/lib/dairy.js",
      ]
  end

end
