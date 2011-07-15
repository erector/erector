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

  def test_render(&block)
    Erector::Rails.render(Erector.inline(&block), @view)
  end

  describe "#link_to" do
    it "renders a link" do
      test_render do
        link_to 'Test', '/foo'
      end.should == %{<a href="/foo">Test</a>}
    end

    it "supports blocks" do
      test_render do
        link_to '/foo' do
          strong "Test"
        end
      end.should == %{<a href="/foo"><strong>Test</strong></a>}
    end

    it "escapes input" do
      test_render do
        link_to 'This&that', '/foo?this=1&amp;that=1'
      end.should == %{<a href="/foo?this=1&amp;that=1">This&amp;that</a>}
    end

    it "isn't double rendered when 'text link_to' is used by mistake" do
      test_render do
        text link_to('Test', '/foo')
      end.should == %{<a href="/foo">Test</a>}
    end
  end

  describe "a regular helper" do
    it "can be called directly" do
      test_render do
        text truncate("foo")
      end.should == "foo"
    end

    it "can be called via capture" do
      test_render do
        text capture { text truncate("foo") }
      end.should == "foo"
    end

    it "can be called via sub-widget" do
      test_render do
        widget Erector.inline { text truncate("foo") }
      end.should == "foo"
    end
  end

  describe "a named route helper" do
    before do
      ActionController::Routing::Routes.draw do |map|
        map.root :controller => "rails_helpers_spec"
      end
    end

    it "can be called directly" do
      test_render do
        text root_path
      end.should == "/"
    end

    it "can be called via parent" do
      test_render do
        text parent.root_path
      end.should == "/"
    end

    it "respects default_url_options defined by the controller" do
      def @controller.default_url_options(options = nil)
        { :host => "www.override.com" }
      end

      test_render do
        text root_url
      end.should == "http://www.override.com/"
    end
  end

  describe "#auto_discovery_link_tag" do
    it "renders tag" do
      test_render do
        auto_discovery_link_tag(:rss, "rails")
      end.should == %{<link href="rails" rel="alternate" title="RSS" type="application/rss+xml" />}
    end
  end

  describe "#javascript_include_tag" do
    it "renders tag" do
      test_render do
        javascript_include_tag("rails")
      end.should == %{<script src="/javascripts/rails.js" type="text/javascript"></script>}
    end
  end

  describe "#stylesheet_link_tag" do
    it "renders tag" do
      test_render do
        stylesheet_link_tag("rails")
      end.should == %{<link href="/stylesheets/rails.css" media="screen" rel="stylesheet" type="text/css" />}
    end
  end

  describe "#image_tag" do
    it "renders tag" do
      test_render do
        image_tag("/foo")
      end.should == %{<img alt="Foo" src="/foo" />}
    end
  end

  describe "#javascript_tag" do
    it "renders tag" do
      test_render do
        javascript_tag "alert('All is good')"
      end.should == %{<script type="text/javascript">\n//<![CDATA[\nalert('All is good')\n//]]>\n</script>}
    end

    it "supports block syntax" do
      test_render do
        javascript_tag do
          text! "alert('All is good')"
        end
      end.should == %{<script type="text/javascript">\n//<![CDATA[\nalert('All is good')\n//]]>\n</script>}
    end
  end

  [:sortable_element,
   :draggable_element,
   :drop_receiving_element].each do |helper|
    describe "##{helper}" do
      it "renders helper js" do
        test_render do
           send(helper, "rails", :url => "/foo")
        end.should =~ %r{<script type="text/javascript">.*</script>}m
      end
    end
  end

  describe "#link_to_function" do
    context "when passed a string for the js function" do
      it "renders a link with the name as the content and the onclick handler" do
        test_render do
          link_to_function("hi", "alert('hi')")
        end.should == "<a href=\"#\" onclick=\"alert('hi'); return false;\">hi</a>"
      end
    end

    context "when passed a block for the js function" do
      it "renders the name and the block rjs contents onto onclick" do
        test_render do
          link_to_function("Show me more", nil, :id => "more_link") do |page|
            page[:details].visual_effect  :toggle_blind
            page[:more_link].replace_html "Show me less"
          end
        end.should == "<a href=\"#\" id=\"more_link\" onclick=\"$(&quot;details&quot;).visualEffect(&quot;toggle_blind&quot;);\n$(&quot;more_link&quot;).update(&quot;Show me less&quot;);; return false;\">Show me more</a>"
      end
    end
  end

  describe "#render" do
    it "renders text" do
      test_render do
        render :text => "Test"
      end.should == "Test"
    end
  end

  describe "#error_messages_for" do
    it "renders the error message" do
      pending "RR problem with Ruby 1.9" if RUBY_VERSION >= "1.9.0"

      user_class = BaseDummyModel
      stub(user_class).human_attribute_name {'User'}
      user = user_class.new
      stub(user).name {'bob'}
      errors = ActiveRecord::Errors.new(user)
      errors.add("name", "must be unpronounceable")
      stub(user).errors {errors}

      @controller.user = user

      test_render do
        error_messages_for('user')
      end.should == "<div class=\"errorExplanation\" id=\"errorExplanation\"><h2>1 error prohibited this user from being saved</h2><p>There were problems with the following fields:</p><ul><li>User must be unpronounceable</li></ul></div>"
    end
  end

  describe "#form_tag" do
    it "works without a block" do
      test_render do
        form_tag("/posts")
      end.should == %{<form action="/posts" method="post">}
    end

    it "can be mixed with erector and rails helpers" do
      test_render do
        form_tag("/posts") do
          div { submit_tag 'Save' }
        end
      end.should == %{<form action="/posts" method="post"><div><input name="commit" type="submit" value="Save" /></div></form>}
    end
  end

  describe "#form_for" do
    it "produces expected output" do
      test_render do
        form_for(:something, :url => "/test") do |form|
          form.label :my_input, "My input"
          form.text_field :my_input
        end
      end.should == %{<form action="/test" method="post"><label for="something_my_input">My input</label><input id="something_my_input" name="something[my_input]" size="30" type="text" /></form>}
    end

    it "doesn't double render if 'text form.label' is used by mistake" do
      test_render do
        form_for(:something, :url => "/test") do |form|
          text form.label(:my_input, "My input")
        end
      end.should == %{<form action="/test" method="post"><label for="something_my_input">My input</label></form>}
    end
  end
end
