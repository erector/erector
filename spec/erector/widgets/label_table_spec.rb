require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe LabelTable do

  describe "a basic, brittle characterization test, just to get up and running" do

    class PasswordForm < Erector::Widget
      def content
        form :action => "/user", :method => "post" do
          widget(LabelTable.new(:title => "Sign Up") do
            field("Name") do
              input(:name => "name", :type => "text", :size => "30", :value => @username)
            end
            field("Password") do
              input(:name => "password", :type => "password", :size => "30")
            end
            field("Password Again", 
            "Yes, we really want you to type your new password twice, for some reason.") do
              input(:name => "password_verify", :type => "password", :size => "30")
            end
            button do
              input(:name => "signup", :type => "submit", :value => "Sign Up")
            end
          end)
        end
      end
    end

    it "renders the CreateUser form" do
      PasswordForm.new(:username => "bobdole").to_s.should == 
      "<form action=\"/user\" method=\"post\">" + 
      "<fieldset class=\"label_table\">" + 
      "<legend>Sign Up</legend>" +
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
      "Yes, we really want you to type your new password twice, for some reason.</td>" + 
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
  
  describe "using the classic API from outside" do
    
    it "renders an empty form" do
      table = LabelTable.new(:title => "Meals")
      doc = Nokogiri::HTML(table.to_s)
      doc.css("fieldset legend").text.should == "Meals"
      doc.at("fieldset")["class"].should == "label_table"
    end
    
  end
end
