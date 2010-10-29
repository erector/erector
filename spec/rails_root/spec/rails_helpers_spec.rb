require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")

describe Erector::Rails do
  before do
    @controller = ActionController::Base.new
    @controller.request = ActionController::TestRequest.new

    @view = ActionView::Base.new
    @view.controller = @controller

    def @view.protect_against_forgery?
      false
    end
  end

  def test_render(&block)
    Erector::Rails.render(Erector.inline(&block), @controller.view_context)
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
        link_to 'This&that', '/foo?this=1&that=1'
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
      Rails.application.routes.draw do
        root :to => "rails_helpers_spec#index"
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
      end.should =~ %r{<script src="/javascripts/rails.js(?:\?\d+)?" type="text/javascript"></script>}
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

  describe "#render" do
    it "renders text" do
      test_render do
        render :text => "Test"
      end.should == "Test"
    end
  end

  describe "#form_tag" do
    it "works without a block" do
      test_render do
        form_tag("/posts")
      end.should == %{<form accept-charset="UTF-8" action="/posts" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div>}
    end

    it "can be mixed with erector and rails helpers" do
      test_render do
        form_tag("/posts") do
          div { submit_tag 'Save' }
        end
      end.should == %{<form accept-charset="UTF-8" action="/posts" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><div><input name="commit" type="submit" value="Save" /></div></form>}
    end
  end

  describe "#form_for" do
    it "produces expected output" do
      test_render do
        form_for(:something, :url => "/test") do |form|
          form.label :my_input, "My input"
          form.text_field :my_input
        end
      end.should == %{<form accept-charset="UTF-8" action="/test" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><label for="something_my_input">My input</label><input id="something_my_input" name="something[my_input]" size="30" type="text" /></form>}
    end

    it "doesn't double render if 'text form.label' is used by mistake" do
      test_render do
        form_for(:something, :url => "/test") do |form|
          text form.label(:my_input, "My input")
        end
      end.should == %{<form accept-charset="UTF-8" action="/test" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><label for="something_my_input">My input</label></form>}
    end

    it "can be called from a nested widget" do
      test_render do
        widget Erector.inline { form_for(:something, :url => "/test") {|form| form.text_field :my_input} }
      end.should =~ /^<form/
    end

    it "uses the specified builder" do
      builder = Class.new(ActionView::Base.default_form_builder) do
        def foo
          "foo"
        end
      end

      test_render do
        form_for(:something, :url => "/test", :builder => builder) do |form|
          text form.foo
        end
      end.should =~ /foo/
    end
  end
end
