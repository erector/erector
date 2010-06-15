require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module Erector
  module Widgets

    describe FieldTable do

      describe "a basic, brittle characterization test, just to get up and running" do

        class PasswordForm < Erector::Widget
          def content
            form :action => "/user", :method => "post" do
              widget(FieldTable.new(:title => "Sign Up") do |t|
                t.field("Name") do
                  input(:name => "name", :type => "text", :size => "30", :value => @username)
                end
                t.field("Password") do
                  input(:name => "password", :type => "password", :size => "30")
                end
                t.field("Password Again",
                        "Yes, we really want you to type your new password twice, for some reason.") do
                  input(:name => "password_verify", :type => "password", :size => "30")
                end
                t.button do
                  input(:name => "signup", :type => "submit", :value => "Sign Up")
                end
              end)
            end
          end
        end

        it "renders the CreateUser form" do
          PasswordForm.new(:username => "bobdole").to_html.should ==
            "<form action=\"/user\" method=\"post\">" +
              "<fieldset class=\"field_table\">" +
              "<legend>Sign Up</legend>" +
              "<table width=\"100%\">" +
              "<tr class=\"field_table_field\">" +
              "<th>" +
              "Name:</th>" +
              "<td>" +
              "<input name=\"name\" size=\"30\" type=\"text\" value=\"bobdole\" />" +
              "</td>" +
              "</tr>" +
              "<tr class=\"field_table_field\">" +
              "<th>" +
              "Password:</th>" +
              "<td>" +
              "<input name=\"password\" size=\"30\" type=\"password\" />" +
              "</td>" +
              "</tr>" +
              "<tr class=\"field_table_field\">" +
              "<th>" +
              "Password Again:</th>" +
              "<td>" +
              "<input name=\"password_verify\" size=\"30\" type=\"password\" />" +
              "</td>" +
              "<td>" +
              "Yes, we really want you to type your new password twice, for some reason.</td>" +
              "</tr>" +
              "<tr class=\"field_table_buttons\">" +
              "<td align=\"right\" colspan=\"2\">" +
              "<table class=\"layout\">" +
              "<tr>" +
              "<td class=\"field_table_button\">" +
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

      describe "using the configuration API to construct it on the fly" do

        it "renders a table with no fields and no buttons" do
          table = FieldTable.new(:title => "Meals")
          doc = Nokogiri::HTML(table.to_html)
          doc.css("fieldset legend").text.should == "Meals"
          doc.at("fieldset")["class"].should == "field_table"
          doc.css("fieldset > table > tr").size.should == 0
        end

        it "renders a table with no fields and one button" do
          table = FieldTable.new(:title => "Meals") do |t|
            t.button { t.input :type => "button", :value => "cancel" }
          end
          doc = Nokogiri::HTML(table.to_html)
          doc.css("fieldset > table > tr").size.should == 1
          doc.at("fieldset table tr")["class"].should == "field_table_buttons"
          doc.at("td.field_table_button input")["value"].should == "cancel"
        end

        it "renders a table with a field and no buttons" do
          table = FieldTable.new(:title => "Meals") do |t|
            t.field("Breakfast") { t.text "scrambled eggs" }
          end
          doc = Nokogiri::HTML(table.to_html)
          doc.css("fieldset > table > tr").size.should == 1
          doc.at("fieldset table tr")["class"].should == "field_table_field"
          doc.at("fieldset table tr th").text.should == "Breakfast:"
          doc.at("fieldset table tr td").text.should == "scrambled eggs"
        end

        it "renders a table with a field with no label" do
          table = FieldTable.new(:title => "Meals") do |t|
            t.field { t.text "yum yum" }
          end
          doc = Nokogiri::HTML(table.to_html)
          doc.css("fieldset > table > tr").size.should == 1
          doc.at("fieldset table tr")["class"].should == "field_table_field"
          doc.at("fieldset table tr th").text.should == ""
          doc.at("fieldset table tr td").text.should == "yum yum"
        end

        it 'puts in an extra cell if you pass in a note' do
          table = FieldTable.new(:title => "Meals") do |t|
            t.field("Breakfast", "the most important meal of the day") { t.text "eggs" }
            t.field("Lunch") { t.text "hot dogs" }
          end
          doc = Nokogiri::HTML(table.to_html)
          doc.at("fieldset table tr").css("td[3]").text.should == "the most important meal of the day"
        end

      end
    end
  end
end
