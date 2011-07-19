require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

require "erector/promise"
# a "promise" is my working name for a pointer back into the output stream, so we can rewrite the current tag (or a different one)
module Erector
  describe Promise do
    before do
      @buffer = []
      @output = Output.new(:buffer => @buffer)
    end

    it "has a tag name" do
      promise = Promise.new(@output, "foo")
      promise._tag_name.should == "foo"
    end

    it "can have attributes" do
      promise = Promise.new(@output, "foo", :att => "val")
      promise._tag_name.should == "foo"
      promise._attributes.should == {"att" => "val"}
    end

    it "turns a dot call into a 'class' attribute" do
      promise = Promise.new(@output, "foo")
      promise.logo
      promise._tag_name.should == "foo"
      promise._attributes.should == {"class" => "logo"}
    end

    it "appends dot calls to an existing class attribute" do
      promise = Promise.new(@output, "foo", :class => "logo")
      promise.header
      promise._attributes.should == {"class" => "logo header"}
    end

    it "chains dot calls" do
      promise = Promise.new(@output, "foo")
      promise.logo
      promise.header
      promise._attributes.should == {"class" => "logo header"}
    end

    it "turns a dot-bang call into an 'id' attribute" do
      promise = Promise.new(@output, "foo")
      promise.logo!
      promise._tag_name.should == "foo"
      promise._attributes.should == {"id" => "logo"}
    end

    it "fails if an id is already present" do
      promise = Promise.new(@output, "foo", :id => 'logo')
      lambda {
        promise.logo!
      }.should raise_error(ArgumentError)
    end

    describe '#_render' do
      it "renders an empty tag" do
        promise = Promise.new(@output, "foo")
        promise._render
        @output.to_s.should == "<foo></foo>"
      end

      it "renders an empty tag" do
        promise = Promise.new(@output, "foo")
        promise._render
        @output.to_s.should == "<foo></foo>"
      end

      it "renders a self-closing tag" do
        promise = Promise.new(@output, "foo", {}, true)
        promise._render
        @output.to_s.should == "<foo />"
      end

      it "renders RawStrings for open and close" do
        promise = Promise.new(@output, "foo")
        promise._render
        @buffer.each{|s| s.should be_a(RawString)}
      end

      it "fills its target with attributes" do
        promise = Promise.new(@output, "foo", :bar => "baz")
        promise._render
        @output.to_s.should == "<foo bar=\"baz\"></foo>"
      end

      it "replaces its target after a dot call" do
        promise = Promise.new(@output, "foo")
        promise._render
        promise.logo
        promise._render
        @output.to_s.should == "<foo class=\"logo\"></foo>"
      end

      it "replaces its target after two dot calls" do
        promise = Promise.new(@output, "foo")
        promise.logo.header
        @output.to_s.should == "<foo class=\"logo header\"></foo>"
      end
    end
  end
end

describe Erector::HTML do
  include Erector::Mixin

  describe "#element" do
    it "returns a promise" do
      erector {
        div.should be_a(Erector::Promise)
      }.should == "<div></div>"
    end

    it "re-renders the open tag when the promise changes" do
      erector {
        div.header
      }.should == "<div class=\"header\"></div>"
    end

    it "re-renders the open tag when passed a hash" do
      erector {
        div.header :style => 'font-size: 10px'
      }.should == "<div class=\"header\" style=\"font-size: 10px\"></div>"
    end

    it "re-renders the inside tag when passed a string" do
      erector {
        div.header "welcome"
      }.should == "<div class=\"header\">welcome</div>"
    end

    it "re-renders the open and inside when passed a string and a hash" do
      erector {
        div.header "welcome", :style => 'font-size: 10px'
      }.should == "<div class=\"header\" style=\"font-size: 10px\">welcome</div>"
    end

    it "re-renders the inside tag when passed a block" do
      erector {
        div.header do
          p "welcome"
        end
      }.should == "<div class=\"header\"><p>welcome</p></div>"
    end

    it "totally works" do
      erector {
        div.header.zomg!.zoom "hi"
        div.main :style => 'font-size: 12pt' do
          p "hello"
        end
        div.footer! do
          img.logo! :src=>"logo.gif"
          text "OmniCorp"
        end
      }.should == "<div class=\"header zoom\" id=\"zomg\">hi</div>" +
      "<div class=\"main\" style=\"font-size: 12pt\"><p>hello</p></div>" +
      "<div id=\"footer\">" +
      "<img id=\"logo\" src=\"logo.gif\" />" +
      "OmniCorp" +
      "</div>"
    end

  end

end



      # newlines and indentation

      # self-closing tags
