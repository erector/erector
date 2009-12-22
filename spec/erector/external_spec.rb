require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")
require 'benchmark'
require 'active_support' # for Symbol#to_proc

describe Erector::External do
  it "can be constructed with type, klass, text" do
    x = Erector::External.new(:foo, "abc")
    x.type.should == :foo
    x.text.should == "abc"
    x.options.should == {}
  end

  it "can be constructed with type, text, and options" do
    x = Erector::External.new(:foo, "abc", {:bar => 7})
    x.options.should == {:bar => 7}
  end
  
  it "can be constructed with a file" do
    file = File.new("#{File.dirname(__FILE__)}/sample-file.txt")
    x = Erector::External.new(:foo, file)
    x.text.should == "sample file contents, 2 + 2 = 4\n"
  end

  it "is equal to an identical external" do
    x = Erector::External.new(:foo, "abc", {:bar => 7})
    y = Erector::External.new(:foo, "abc", {:bar => 7})
    x.should == y
    [x].should include(y)
  end
  
  it "is not equal to an otherwise identical external with different options" do
    x = Erector::External.new(:foo, "abc")
    y = Erector::External.new(:foo, "abc", {:bar => 7})
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
  
  class Tabasco < HotSauce
    external :js, "tabasco.js"
    external :css, "/css/salsa_picante.css"
  end

  it "can be fetched via the type" do
    HotSauce.externals(:css).map(&:text).should == [
      "/css/tapatio.css",
      "/css/salsa_picante.css",
      ]
  end
  
  it "can be filtered via the class" do
    SourCream.externals(:css).map(&:text).should == [
      "/css/sourcream.css",
      ]
  end
    
  it "grabs externals from superclasses too" do
    Tabasco.externals(:js).map(&:text).should == ["/lib/jquery.js", "/lib/picante.js", "tabasco.js"]
  end

  it "retains the options" do
    HotSauce.externals(:css).map(&:options).should == [
      {:media => "print"}, 
      {}
    ]
  end
  
  it "removes duplicates" do
    Tabasco.externals(:css).map(&:text).should == [
      "/css/tapatio.css",
      "/css/salsa_picante.css",
      ]
  end

  it "works with strings or symbols" do
    HotSauce.externals("css").map(&:text).should == [
      "/css/tapatio.css",
      "/css/salsa_picante.css",
      ]
  end

  class Taco < Erector::Widget
    external :filling, "beef"
    external :filling, "beef", :media => "print"
  end
    
  it "considers options when removing duplicates" do
    Taco.externals(:filling).map(&:text).should == ["beef", "beef"]
  end
  
  class Enchilada < Erector::Widget
    external :sample, File.new("#{File.dirname(__FILE__)}/sample-file.txt")
  end

  it "loads a file" do
    Enchilada.externals(:sample).map(&:text).should == [
       "sample file contents, 2 + 2 = 4\n"
    ]
  end

end
