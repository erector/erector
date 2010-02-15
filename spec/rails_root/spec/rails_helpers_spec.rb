require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")

describe Erector::Rails::Helpers do
  class RailsHelpersSpecController < ActionController::Base
  end

  before do
    @controller = RailsHelpersSpecController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @controller.send(:initialize_template_class, @response)
    @controller.send(:assign_shortcuts, @request, @response)
    @controller.send(:initialize_current_url)

    @view = ActionView::Base.new
    @view.output_buffer = ""
    @view.controller = @controller

    def @view.protect_against_forgery?
      false
    end

    class << @controller
      public :render

      attr_accessor :user # dummy instance variable for assigns testing
    end
  end

  describe "#link_to" do
    it "renders a link" do
      Erector.inline do
        link_to 'Test', '/foo'
      end.to_s(:helpers => @view).should == %{<a href="/foo">Test</a>}
    end

    it "supports blocks" do
      Erector.inline do
        link_to '/foo' do
          strong "Test"
        end
      end.to_s(:helpers => @view).should == %{<a href="/foo"><strong>Test</strong></a>}
    end

    it "escapes input" do
      pending "http://github.com/nzkoz/rails_xss/issues#issue/1" do
        Erector.inline do
          link_to 'This&that', '/foo?this=1&amp;that=1'
        end.to_s(:helpers => @view).should == %{<a href="/foo?this=1&amp;that=1">This&amp;that</a>}
      end
    end

    it "supports path methods" do
      ActionController::Routing::Routes.draw do |map|
        map.root :controller => "rails_helpers_spec"
      end

      Erector.inline do
        link_to 'Link', helpers.root_path
      end.to_s(:helpers => @view).should == %{<a href="/">Link</a>}
    end
  end

  describe "#auto_discovery_link_tag" do
    it "renders tag" do
      Erector.inline do
        auto_discovery_link_tag(:rss, "rails")
      end.to_s(:helpers => @view).should == %{<link href="rails" rel="alternate" title="RSS" type="application/rss+xml" />}
    end
  end

  describe "#javascript_include_tag" do
    it "renders tag" do
      Erector.inline do
        javascript_include_tag("rails")
      end.to_s(:helpers => @view).should == %{<script src="/javascripts/rails.js" type="text/javascript"></script>}
    end
  end

  describe "#stylesheet_link_tag" do
    it "renders tag" do
      Erector.inline do
        stylesheet_link_tag("rails")
      end.to_s(:helpers => @view).should == %{<link href="/stylesheets/rails.css" media="screen" rel="stylesheet" type="text/css" />}
    end
  end

  describe "#image_tag" do
    it "renders tag" do
      Erector.inline do
        image_tag("/foo")
      end.to_s(:helpers => @view).should == %{<img alt="Foo" src="/foo" />}
    end
  end

  describe "#javascript_tag" do
    it "renders tag" do
      Erector.inline do
        javascript_tag "alert('All is good')"
      end.to_s(:helpers => @view).should == %{<script type="text/javascript">\n//<![CDATA[\nalert('All is good')\n//]]>\n</script>}
    end

    it "supports block syntax" do
      Erector.inline do
        javascript_tag do
          text! "alert('All is good')"
        end
      end.to_s(:helpers => @view).should == %{<script type="text/javascript">\n//<![CDATA[\nalert('All is good')\n//]]>\n</script>}
    end
  end

  [:sortable_element,
   :draggable_element,
   :drop_receiving_element].each do |helper|
    describe "##{helper}" do
      it "renders helper js" do
        @controller.render :widget => Erector.inline { send(helper, "rails", :url => "/foo") }
        @response.body.should =~ %r{<script type="text/javascript">.*</script>}m
      end
    end
  end

  describe "#link_to_function" do
    context "when passed a string for the js function" do
      it "renders a link with the name as the content and the onclick handler" do
        widget_class = Class.new(Erector::Widget) do
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
        widget_class = Class.new(Erector::Widget) do
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

  describe "#render" do
    it "renders text" do
      Erector.inline do
        render :text => "Test"
      end.to_s(:helpers => @view).should == "Test"
    end
  end

  describe "#error_messages_for" do
    it "renders the error message" do
      widget_class = Class.new(Erector::Widget) do
        def content
          error_messages_for('user')
        end
      end

      user_class = BaseDummyModel
      stub(user_class).human_attribute_name {'User'}
      user = user_class.new
      stub(user).name {'bob'}
      errors = ActiveRecord::Errors.new(user)
      errors.add("name", "must be unpronounceable")
      stub(user).errors {errors}

      @controller.user = user

      @controller.render(:widget => widget_class)
      @response.body.should == "<div class=\"errorExplanation\" id=\"errorExplanation\"><h2>1 error prohibited this user from being saved</h2><p>There were problems with the following fields:</p><ul><li>User must be unpronounceable</li></ul></div>"
    end
  end

  describe "#form_tag" do
    it "works without a block" do
      Erector.inline do
        form_tag("/posts")
      end.to_s(:helpers => @view).should == %{<form action="/posts" method="post">}
    end

    it "can be mixed with erector and rails helpers" do
      Erector.inline do
        form_tag("/posts") do
          div { submit_tag 'Save' }
        end
      end.to_s(:helpers => @view).should == %{<form action="/posts" method="post"><div><input name="commit" type="submit" value="Save" /></div></form>}
    end
  end
end
