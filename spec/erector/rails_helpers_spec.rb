require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")
require 'ostruct'
  
module RailsHelpersSpec
  
  class RailsHelpersSpecController < ActionController::Base
  end
  
  describe "Rails helpers" do

    before do
      @controller = RailsHelpersSpecController.new
      @request = ActionController::TestRequest.new
      @response = ActionController::TestResponse.new
      @controller.send(:initialize_template_class, @response)
      @controller.send(:assign_shortcuts, @request, @response)
      @controller.send(:initialize_current_url)
      class << @controller
        public :rendered_widget, :render
        
        attr_accessor :user # dummy instance variable for assigns testing
      end
      @controller.append_view_path("#{RAILS_ROOT}/app/views")
    end

    it "image_tag" do
      class Erector::TestWidget < Erector::Widget
        def render
          image_tag("rails.png")
        end
      end      
      @controller.render :widget => Erector::TestWidget
      @response.body.should == "<img alt=\"Rails\" src=\"/images/rails.png\" />"
    end

    it "javascript_include_tag" do
      class Erector::TestWidget < Erector::Widget
        def render
          javascript_include_tag("rails")
        end
      end      
      @controller.render :widget => Erector::TestWidget
      @response.body.should == "<script src=\"/javascripts/rails.js\" type=\"text/javascript\"></script>"
    end
    
    it "define_javascript_functions" do
      class Erector::TestWidget < Erector::Widget
        def render
          define_javascript_functions
        end
      end      
      @controller.render :widget => Erector::TestWidget
      @response.body.should =~ /^<script type=\"text\/javascript\">\n/
    end
    
    it "stylesheet_link_tag" do
      class Erector::TestWidget < Erector::Widget
        def render
          stylesheet_link_tag("rails")
        end
      end      
      @controller.render :widget => Erector::TestWidget
      @response.body.should == "<link href=\"/stylesheets/rails.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />"
    end

    def sortable_js_for(element_id, url)
      "Sortable.create(\"#{element_id}\", {onUpdate:function(){new Ajax.Request('#{url}', {asynchronous:true, evalScripts:true, parameters:Sortable.serialize(\"#{element_id}\")})}})"
    end

    it "sortable_element" do
      class Erector::TestWidget < Erector::Widget
        def render
          sortable_element("rails", :url => "/foo")
        end
      end      
      @controller.render :widget => Erector::TestWidget
      @response.body.should == 
        "<script type=\"text/javascript\">\n//<![CDATA[\n" + 
        sortable_js_for("rails", "/foo") +
        "\n//]]>\n</script>"
    end

    it "sortable_element_js" do
      class Erector::TestWidget < Erector::Widget
        def render
          sortable_element_js("rails", :url => "/foo")
        end
      end      
      @controller.render :widget => Erector::TestWidget
      @response.body.should == sortable_js_for("rails", "/foo") + ";"
      
    end

    #Note: "text_field_with_auto_complete" is now a plugin, which makes it difficult to test inside the Erector project

    # :link_to_function,
    # :link_to,
    # :link_to_remote,
    # :mail_to,
    # :button_to,
    # :submit_tag,

    describe "which html-escape their first parameter:" do
      it "link_to_function with name" do
        class Erector::TestWidget < Erector::Widget
          def render
            link_to_function("hi", "alert('hi')")
          end
        end      
        @controller.render :widget => Erector::TestWidget
        @response.body.should == "<a href=\"#\" onclick=\"alert('hi'); return false;\">hi</a>"
      end

      it "link_to_function with block" do
        class Erector::TestWidget < Erector::Widget
          def render
            link_to_function("Show me more", nil, :id => "more_link") do |page|
              page[:details].visual_effect  :toggle_blind
              page[:more_link].replace_html "Show me less"
            end
          end
        end
        @controller.render :widget => Erector::TestWidget
        @response.body.should == "<a href=\"#\" id=\"more_link\" onclick=\"$(&quot;details&quot;).visualEffect(&quot;toggle_blind&quot;);\n$(&quot;more_link&quot;).update(&quot;Show me less&quot;);; return false;\">Show me more</a>"
      end
    end

    describe "which render to the ERB stream:" do
      it "error_messages for, with object name" do
        pending("error_messages_for is broken")
        class Erector::TestWidget < Erector::Widget
          def render
            error_messages_for 'user'
          end
        end
        errors = ActiveRecord::Errors.new(nil)
        errors.add("name", "must be unpronounceable")
        @controller.user = OpenStruct.new({:name => 'bob', :errors => errors})
        @controller.render :widget => Erector::TestWidget
        @response.body.should == "<a href=\"#\" onclick=\"alert('hi'); return false;\">hi</a>"
      end
    end

  end
  

end
