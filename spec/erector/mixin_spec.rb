require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")
require 'benchmark'

module MixinSpec
  class Thing
    include Erector::Mixin
  end
  
  describe Erector::Mixin do
    describe "#erector" do
      it "renders its block to a string" do
        
        class MixinSpec::Thing
          def name
            erector do
              span :class => "name" do
                text "Gabriel "
                i "Garcia"
                text " Marquez"
              end
            end
          end
        end
        
        Thing.new.name.should == "<span class=\"name\">Gabriel <i>Garcia</i> Marquez</span>"
      end
      
      it "passes its parameters to to_s" do
        class MixinSpec::Thing
          def pretty_name
            erector(:prettyprint => true) do
              div :class => "name" do
                ul do
                  li "Gabriel"
                  li "Garcia"
                  li "Marquez"
                end
              end
            end
          end
        end
        
        Thing.new.pretty_name.should == 
        "<div class=\"name\">\n" + 
        "  <ul>\n" + 
        "    <li>Gabriel</li>\n" +
        "    <li>Garcia</li>\n" +
        "    <li>Marquez</li>\n" +
        "  </ul>\n" +
        "</div>\n"
      end
    end
  end
end
