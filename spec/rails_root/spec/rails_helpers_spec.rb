require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")
  
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
        public :render
        
        attr_accessor :user # dummy instance variable for assigns testing
      end
    end

    describe "#image_tag" do
      it "renders img tag" do
        widget_class = Class.new(Erector::RailsWidget) do
          def content
            image_tag("rails.png")
          end
        end
        @controller.render :widget => widget_class
        @response.body.should =~ Regexp.new('<img alt="Rails" src="/images/rails.png\??[0-9]*" />')
      end
    end

    describe "#javascript_include_tag" do
      it "renders javascript script tag" do
        widget_class = Class.new(Erector::RailsWidget) do
          def content
            javascript_include_tag("rails")
          end
        end
        @controller.render :widget => widget_class
        @response.body.should == "<script src=\"/javascripts/rails.js\" type=\"text/javascript\"></script>"
      end
    end

    describe "#stylesheet_link_tag" do
      it "renders link tag" do
        widget_class = Class.new(Erector::RailsWidget) do
          def content
            stylesheet_link_tag("rails")
          end
        end
        @controller.render :widget => widget_class
        @response.body.should == "<link href=\"/stylesheets/rails.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />"
      end
    end

    def sortable_js_for(element_id, url)
      "Sortable.create(\"#{element_id}\", {onUpdate:function(){new Ajax.Request('#{url}', {asynchronous:true, evalScripts:true, parameters:Sortable.serialize(\"#{element_id}\")})}})"
    end

    describe "#sortable_elemnt" do
      it "renders sortable helper js" do
        widget_class = Class.new(Erector::RailsWidget) do
          def content
            sortable_element("rails", :url => "/foo")
          end
        end
        @controller.render :widget => widget_class
        @response.body.should ==
        "<script type=\"text/javascript\">\n//<![CDATA[\n" +
        sortable_js_for("rails", "/foo") +
        "\n//]]>\n</script>"
      end
    end

    describe "#sortable_element_js" do
      it "renders only the sortable javascript" do
        widget_class = Class.new(Erector::RailsWidget) do
          def content
            sortable_element_js("rails", :url => "/foo")
          end
        end
        @controller.render :widget => widget_class
        @response.body.should == sortable_js_for("rails", "/foo") + ";"
      end
    end

    #Note: "text_field_with_auto_complete" is now a plugin, which makes it difficult to test inside the Erector project

    # :link_to_function,
    # :link_to,
    # :link_to_remote,
    # :mail_to,
    # :button_to,
    # :submit_tag,

    describe "#link_to_function" do
      context "when passed a string for the js function" do
        it "renders a link with the name as the content and the onclick handler" do
          widget_class = Class.new(Erector::RailsWidget) do
            def content
              link_to_function("hi", "alert('hi')")
            end
          end
          @controller.render :widget => widget_class
          @response.body.should == "<a href=\"#\" onclick=\"alert('hi'); return false;\">hi</a>"
        end
      end

      context "when passed a block for the js function" do
        it "renders the name and the block rjs contents onto onclick" do
          widget_class = Class.new(Erector::RailsWidget) do
            def content
              link_to_function("Show me more", nil, :id => "more_link") do |page|
                page[:details].visual_effect  :toggle_blind
                page[:more_link].replace_html "Show me less"
              end
            end
          end
          @controller.render :widget => widget_class
          @response.body.should == "<a href=\"#\" id=\"more_link\" onclick=\"$(&quot;details&quot;).visualEffect(&quot;toggle_blind&quot;);\n$(&quot;more_link&quot;).update(&quot;Show me less&quot;);; return false;\">Show me more</a>"
        end
      end
    end

    describe "#error_messages_for" do
      it "renders the error message" do
        widget_class = Class.new(Erector::RailsWidget) do
          def content
            rawtext error_messages_for('user')
          end
        end

        user_class = Class.new
        stub(user_class).human_attribute_name {'User'}
        user = user_class.new
        stub(user).name {'bob'}
        errors = ActiveRecord::Errors.new(user)
        errors.add("name", "must be unpronounceable")
        stub(user).errors {errors}
        
        @controller.user = user
        
        @controller.render :widget => widget_class
        @response.body.should == "<div class=\"errorExplanation\" id=\"errorExplanation\"><h2>1 error prohibited this user from being saved</h2><p>There were problems with the following fields:</p><ul><li>User must be unpronounceable</li></ul></div>"
      end
    end
  end
end
