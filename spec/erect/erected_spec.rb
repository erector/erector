require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

require "erector/erect/erect"

module Erector
  describe Erected do

    it "picks the right file name" do
      Erected.new("foo.html.erb").filename.should == "foo.rb"
      Erected.new("foo.html").filename.should == "foo.rb"
      Erected.new("foo.bar.html").filename.should == "foo.rb"
      Erected.new("foo_bar.html.erb").filename.should == "foo_bar.rb"
      Erected.new("stuff/foo_bar.html.erb").filename.should == "stuff/foo_bar.rb"
    end

    it "picks a nice class name" do
      Erected.new("foo.html.erb").classname.should == "Foo"
      Erected.new("foo.html").classname.should == "Foo"
      Erected.new("foo.bar.html").classname.should == "Foo"
      Erected.new("foo_bar.html.erb").classname.should == "FooBar"
      Erected.new("stuff/foo_bar.html.erb").classname.should == "FooBar"
    end

    it "picks an even nicer class name if it's in a views dir" do
      Erected.new("app/views/stuff/foo_bar.html.erb").classname.should == "Views::Stuff::FooBar"
      Erected.new("views/stuff/foo_bar.html.erb").classname.should == "Views::Stuff::FooBar"
    end

    it "uses Widget as the parent class" do
      Erected.new("foo_bar.html").parent_class.should == "Erector::Widget"
      Erected.new("foo_bar.html.erb").parent_class.should == "Erector::Widget"
      Erected.new("stuff/foo_bar.html.erb").parent_class.should == "Erector::Widget"
    end

    it "uses Widget as the parent class if it's in a views dir" do
      Erected.new("app/views/stuff/foo_bar.html.erb").parent_class.should == "Erector::Widget"
      Erected.new("views/stuff/foo_bar.html.erb").parent_class.should == "Erector::Widget"
    end

    def convert(dir, input, output, superklass = nil, method_name = nil)
      dir = Dir.tmpdir + "/#{Time.now.to_i}" + "/#{dir}"

      FileUtils.mkdir_p(dir)
      html = "#{dir}/dummy.html"
      rb = "#{dir}/dummy.rb"

      File.open(html, "w") do |f|
        f.puts(input)
      end
      
      args = [ html, superklass || 'Erector::Widget', method_name || 'content' ]
      @e = Erected.new(*args)
      @e.convert

      File.read(rb).should == output
    end

    it "converts a normal file" do
      convert(".",
        "<div>hello</div>",
        "class Dummy < Erector::Widget\n" +
          "  def content\n" +
          "    div do\n" +
          "      text 'hello'\n" +
          "    end\n" +
          "  end\n" +
          "end\n"
      )
    end

    it "converts a views file" do
      convert("app/views/foos",
        "<div>hello</div>",
        "class Views::Foos::Dummy < Erector::Widget\n" +
          "  def content\n" +
          "    div do\n" +
          "      text 'hello'\n" +
          "    end\n" +
          "  end\n" +
          "end\n"
      )
    end
    
    it "converts a normal file with a different superclass" do
      convert(".",
        "<div>hello</div>",
        "class Dummy < Foo::Bar\n" +
          "  def content\n" +
          "    div do\n" +
          "      text 'hello'\n" +
          "    end\n" +
          "  end\n" +
          "end\n",
        "Foo::Bar"
      )
    end
    
    it "converts a normal file with a different superclass and method name" do
      convert(".",
        "<div>hello</div>",
        "class Dummy < Foo::Bar\n" +
          "  def my_content\n" +
          "    div do\n" +
          "      text 'hello'\n" +
          "    end\n" +
          "  end\n" +
          "end\n",
        "Foo::Bar",
        'my_content'
      )
    end
    
    it "ignores ERb trim markers" do
      convert(".",
        %{<div>
<%= 1 + 3 -%>
</div>},
%{class Dummy < Erector::Widget
  def content
    div do
      rawtext 1 + 3
    end
  end
end
})
    end

    it "converts ERb escapes in attributes" do
      convert(".",
        "<div id=\"foo_<%= bar %>_baz_<%= quux %>_marph\">hello</div>",
%{class Dummy < Erector::Widget
  def content
    div(:id => ('foo_' + bar + '_baz_' + quux + '_marph')) do
      text 'hello'
    end
  end
end
})
    end

    it "only parenthesizes ERb escapes in attributes if necessary" do
      convert(".",
        "<div id=\'<%= bar %>\'>hello</div>",
%{class Dummy < Erector::Widget
  def content
    div :id => bar do
      text 'hello'
    end
  end
end
})
    end

# todo: figure out if there is any such thing as unparsable HTML anymore
#    it "raises an exception if given unparsable HTML" do
#      begin
#        convert(".", "<", "")
#      rescue => e
#        e.to_html.should include("Could not parse")
#      end
#    end
    
  end
end
