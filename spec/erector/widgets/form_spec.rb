require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe Form do

  include Erector::Mixin

  it "defaults to POST, with no magic hidden method param" do
    Form.new(:action => "/foo").to_html.should == "<form action=\"/foo\" method=\"post\"></form>"
  end

  it "works plainly with GET too" do
    Form.new(:action => "/foo", :method => "get").to_html.should == "<form action=\"/foo\" method=\"get\"></form>"
  end
  
  it "uses POST and adds a magic hidden field with a _method param for DELETE" do
    Form.new(:action => "/foo", :method => "delete").to_html.should ==
      "<form action=\"/foo\" method=\"post\">"+
      "<input name=\"_method\" type=\"hidden\" value=\"delete\" />"+
      "</form>"
  end

  it "executes its block in the caller's 'self' context" do
    erector {
      @pet = "dog"
      widget(Form.new(:action => "/foo") do
        p @pet
      end)  
    }.should == "<form action=\"/foo\" method=\"post\"><p>dog</p></form>"
  end

end
