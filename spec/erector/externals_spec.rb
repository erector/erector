require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")
require 'benchmark'
require 'active_support' # for Symbol#to_proc

module ExternalsSpec

  # note, the specs above are duplicative of this + external_spec code
  describe "adding dependencies" do
    before do
      @args = [:what, :ever, :is, :passed]
      @result = Erector::Dependency.new :js, '/foo.js'
      @result2 = Erector::Dependency.new :css, '/foo.css'
    end

    it "calls #interpret_args with given arguments and passes result to #push_dependency" do
      mock(Erector::Widget).interpret_args(*@args).returns(@result)
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
      it "collects a list of dependencies" do
        PushyWidget.push_dependency @result, @result2
        PushyWidget.instance_variable_get(:@externals).should == [@result, @result2]
      end

      it "collects an array of dependencies" do
        PushyWidget.push_dependency [@result, @result2]
        PushyWidget.instance_variable_get(:@externals).should == [@result, @result2]
      end
    end

    it "starts out with no items in @externals" do
      class Quesadilla < Erector::Widget
      end
      (Quesadilla.instance_variable_get(:@externals) || []).should == []
    end


    describe 'Externals#interpret_args' do

      class Test
        include Erector::Externals
      end

      it "will infer that a .js extension is javascript" do
        x = Test.interpret_args('/path/to/a.js')
        x.text.should == '/path/to/a.js'
        x.type.should == :js
      end

      it "will infer that a .css extension is a stylesheet" do
        x = Test.interpret_args('/path/to/a.css')
        x.text.should == '/path/to/a.css'
        x.type.should == :css
      end

      it "will capture render options when just a file is mentioned" do
        x = Test.interpret_args('/path/to/a.css', :render=>:link)
        x.text.should == '/path/to/a.css'
        x.type.should == :css
        x.options.should == {:render=>:link} # could also be "embed"
      end

      it "embeds javascript" do
        x = Test.interpret_args :js, "alert('foo')"
        x.text.should == "alert('foo')"
        x.type.should == :js
      end

      it "guesses Javascript type from .js" do
        x = Test.interpret_args :js, "/script/foo.js"
        x.text.should == "/script/foo.js"
        x.type.should == :js
      end
    end

  end

  describe 'extracting the dependencies (integration tests)' do

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


  end
end
