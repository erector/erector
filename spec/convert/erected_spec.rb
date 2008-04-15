dir = File.dirname(__FILE__)
require "#{dir}/../spec_helper"
require "#{dir}/../../lib/erector/erected"
require 'tempfile'

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

    def convert(dir, input, output)
      dir = Dir.tmpdir + "/#{Time.now.to_i}" + "/#{dir}"

      FileUtils.mkdir_p(dir)
      html = "#{dir}/dummy.html"
      rb = "#{dir}/dummy.rb"

      File.open(html, "w") do |f|
        f.puts(input)
      end

      @e = Erected.new(html)
      @e.convert

      File.read(rb).should == output
    end

    it "converts a normal file" do
      convert(".",
        "<div>hello</div>",
        "class Dummy < Erector::Widget\n" +
          "  def render\n" +
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
          "  def render\n" +
          "    div do\n" +
          "      text 'hello'\n" +
          "    end\n" +
          "  end\n" +
          "end\n"
      )
    end

    it "raises an exception if given unparsable HTML" do
      begin
        convert(".", "<", "")
      rescue => e
        e.to_s.should include("Could not parse")
      end
    end
    
  end
end

