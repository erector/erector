require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe LabelTable do

  class PasswordForm < Erector::Widget
    needs :username => nil
    
    attr_reader :username
    
    def submit_button_name
      @username ? "Change Password" : "Sign Up"
    end
    
    def content
      form :action => "/user", :method => "post" do
        widget(LabelTable.new(:title => submit_button_name) do
          field("Name") do
            input(:name => "name", :type => "text", :size => "30", :value => username)
          end
          field("Password") do
            input(:name => "password", :type => "password", :size => "30")
          end
          field("Password Again", 
            "Yes, we really want you to type your new password twice. Sorry about that.") do
            input(:name => "password_verify", :type => "password", :size => "30")
          end
          button do
            input(:name => "", :type => "submit", :value => submit_button_name)
          end
        end)
      end
    end
  end

  # this is a brittle characterization test, just to get up and running
  it "renders the CreateUser form" do
    PasswordForm.new(:username => "bobdole").to_s.should == "<form action=\"/user\" method=\"post\">" + 
      "<fieldset>" + 
      "<legend>" + 
      "Sign Up</legend>" + 
      "<table width=\"100%\">" + 
      "<tr>" + 
      "<th>" + 
      "Name:</th>" + 
      "<td>" + 
      "<input name=\"name\" size=\"30\" type=\"text\" />" + 
      "</td>" + 
      "</tr>" + 
      "<tr>" + 
      "<th>" + 
      "Password:</th>" + 
      "<td>" + 
      "<input name=\"password\" size=\"30\" type=\"password\" />" + 
      "</td>" + 
      "</tr>" + 
      "<tr>" + 
      "<th>" + 
      "Password Again:</th>" + 
      "<td>" + 
      "<input name=\"password_verify\" size=\"30\" type=\"password\" />" + 
      "</td>" + 
      "<td>" + 
      "Yes, we really want you to type your new password twice. Sorry about that.</td>" + 
      "</tr>" + 
      "<tr>" + 
      "<td align=\"right\" colspan=\"2\">" + 
      "<table class=\"layout\">" + 
      "<tr>" + 
      "<td>" + 
      "<input name=\"signup\" type=\"submit\" value=\"Sign Up\" />" + 
      "</td>" + 
      "</tr>" + 
      "</table>" + 
      "</td>" + 
      "</tr>" + 
      "</table>" + 
      "</fieldset>" + 
      "</form>"
    
  end
end
