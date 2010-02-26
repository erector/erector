require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")
require 'benchmark'
require 'active_support' # for Symbol#to_proc

module DependsOnSpec
describe 'Widget#depends_on' do

  class HotSauce < Erector::Widget
    depends_on :css, "/css/tapatio.css", :media => "print"
    depends_on :css, "/css/salsa_picante.css"
    depends_on :js, "/lib/jquery.js"
    depends_on :js, "/lib/picante.js"
  end

  class SourCream < Erector::Widget
    depends_on :css, "/css/sourcream.css"
    depends_on :js, "/lib/jquery.js"
    depends_on :js, "/lib/dairy.js"
  end
  
  class Tabasco < HotSauce
    depends_on :js, "tabasco.js"
    depends_on :css, "/css/salsa_picante.css"
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
    depends_on :filling, "beef"
    depends_on :filling, "beef", :media => "print"
  end

  it "considers options when removing duplicates" do
    Taco.externals(:filling).map(&:text).should == ["beef", "beef"]
  end

  class Enchilada < Erector::Widget
    depends_on :sample, File.new("#{File.dirname(__FILE__)}/sample-file.txt")
  end

  it "loads a file" do
    Enchilada.externals(:sample).map(&:text).should == [
        "sample file contents, 2 + 2 = \#{2 + 2}\n"
    ]
  end

  class InterpolatedEnchilada < Erector::Widget
    depends_on :sample, File.new("#{File.dirname(__FILE__)}/sample-file.txt"), :interpolate => true
  end

  it "loads a file and interpolates its contents" do
    InterpolatedEnchilada.externals(:sample).map(&:text).should == [
        "sample file contents, 2 + 2 = 4\n"
    ]
  end

  it "embeds javascript" do
    class Chimichanga < Erector::Widget
      depends_on :js, "alert('foo')"
    end
    Chimichanga.externals(:js).first.text.should == "alert('foo')"
    Chimichanga.externals(:js).first.type.should == :js
  end

  it "guesses Javascript type from .js" do
    class FishTaco < Erector::Widget
      depends_on "/script/foo.js"
    end
    FishTaco.externals(:js).first.text.should == "/script/foo.js"
    FishTaco.externals(:js).first.type.should == :js
  end

  # note, the specs above are duplicative of this + external_spec code
  describe "collection of externals" do
    before do
      @args = [:what, :ever, :is, :passed]
      @result = Erector::Dependency.new("here.js")
      @result2 = Erector::Dependency.new("there.js")
    end
    
    it "calls Dependency.new with given arguments and passes them to #push_dependency" do
      mock(Erector::Dependency).new.with(*@args).returns(@result)
      mock(Erector::Widget).push_dependency(@result)
      Erector::Widget.depends_on *@args
    end

    describe "#push_dependency" do
      class PushyWidget < Erector::Widget
      end
      
      it "collects the result of Dependency.new" do
        PushyWidget.push_dependency @result
        PushyWidget.push_dependency @result2
        PushyWidget.instance_variable_get(:@externals).should == [@result, @result2]
      end
    end

    it "starts out with no items in @externals" do
      class Quesadilla < Erector::Widget
      end
      (Quesadilla.instance_variable_get(:@externals) || []).should == []
    end

  end

end
end
