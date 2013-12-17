require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe Erector::Caching do
  include Erector::Mixin

  class Cash < Erector::Widget
    needs :name
    cachable # this is correct, just an alias

    def content
      p do
        text @name
        text " Cash"
      end
    end
  end

  class CashWithVersion < Erector::Widget
    needs :name
    cachable 'v2'

    def content
      p do
        text @name
        text " Cash 2"
      end
    end
  end

  class CashWithComplexKey < Erector::Widget
    needs :sites
    cachable

    def content
      text @sites.first.name
    end
  end

  class Family < Erector::Widget
    cacheable

    def content
      widget Cash, :name => "Johnny"
      widget Cash, :name => "June"
    end
  end

  class ModelCash < Erector::Widget
    cacheable

    def content
      text @model.name
    end
  end

  class NotCachable < Erector::Widget
    def content
      text "CONTENT"
    end
  end

  before do
    ::Rails.cache.clear
    @cache = Erector::Cache.instance
  end

  it "has a global cache" do
    Erector::Widget.cache.should == @cache
  end

  it '-- a widget is not cachable by default' do
    Erector::Widget.cachable?.should be_false
  end

  it '-- a widget is cachable if you say so in the class definition' do
    Cash.cachable?.should be_true
  end

  it '-- can be declared cachable using the alternate spelling "cacheable"' do
    Family.cachable?.should be_true
  end

  describe '#to_html' do

    it "caches a rendered widget" do
      Cash.new(:name => "Johnny").to_html
      @cache[Cash, {:name => "Johnny"}].should == "<p>Johnny Cash</p>"
    end

    it "uses a cache version for the class" do
      CashWithVersion.new(:name => "Johnny").to_html
      @cache[CashWithVersion, 'v2', {:name => "Johnny"}].should == "<p>Johnny Cash 2</p>"
    end

    it "handles complex keys" do
      site1 = OpenStruct.new(name: 'site one name')
      site2 = OpenStruct.new(name: 'site two name')
      site3 = OpenStruct.new(name: 'site three name')
      CashWithComplexKey.new(sites: [site1, site2]).to_html
      @cache[CashWithComplexKey, sites: [site1, site2]].should == "site one name"
      CashWithComplexKey.new(sites: [site3, site1, site2]).to_html.should == "site three name"
    end

    it "calls :cache_key" do
      model = OpenStruct.new(name: 'Myname', cache_key: 'two')
      ModelCash.new(:model => model).to_html
      @cache[ModelCash, { model: 'two' }].should == "Myname"
    end

    it "uses the cached value" do
      @cache[Cash, {:name => "Johnny"}] = "CACHED"
      Cash.new(:name => "Johnny").to_html.should == "CACHED"
    end

    it "doesn't use the cached value for widgets not declared cachable" do
      @cache[NotCachable] = "CACHED"
      NotCachable.new.to_html.should == "CONTENT"
    end

    it "doesn't cache widgets not declared cachable" do
      NotCachable.new.to_html
      @cache[NotCachable].should be_nil
    end

    it "doesn't cache widgets initialized with a block (yet)" do
      Cash.new(:name => "June") do
        text "whatever"
      end.to_html
      @cache[Cash, {:name => "June"}].should be_nil
    end

    it "caches distinct values when using :content_method_name" do
      widget = Class.new(Erector::Widget) do
        cacheable

        def foo
          text "foo"
        end

        def bar
          text "bar"
        end
      end

      widget.new.to_html(:content_method_name => :foo).should == "foo"
      widget.new.to_html(:content_method_name => :bar).should == "bar"
    end

    it "works when passing an existing output as a parameter to to_html" do
      pending
    end
  end

  describe '#widget' do

    it "caches rendered widgets" do
      Family.new.to_html
      @cache[Cash, {:name => "Johnny"}].to_s.should == "<p>Johnny Cash</p>"
      @cache[Cash, {:name => "June"}].to_s.should == "<p>June Cash</p>"
    end

    it "uses the cached value" do
      @cache[Cash, {:name => "Johnny"}] = "JOHNNY CACHED"
      Family.new.to_html.should == "JOHNNY CACHED<p>June Cash</p>"
    end

    class WidgetWithBlock < Erector::Widget
      def content
        call_block
      end
    end

    it "doesn't cache widgets initialized with a block (yet)" do
      erector {
        w = WidgetWithBlock.new do
          text "in block"
        end
        widget w
      }.should == "in block"
      @cache[WidgetWithBlock].should be_nil
    end

  end
end
