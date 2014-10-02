require 'ostruct'
require 'spec_helper'

describe 'Caching' do

  next unless Gem::Version.new(::Rails.version) >= Gem::Version.new('4.0.0')

  class TestCachingController < ActionController::Base
    layout false

    # Let exceptions propagate rather than generating the usual error page.
    include ActionController::TestCase::RaiseActionExceptions

    def cache_helper
    end

    def cache_helper_with_partial
    end

    def cache_helper_with_skip_digest
    end

    def cache_helper_with_implicit_dependencies
    end

    def cacheable_widget_with_needs
      @person = 'person'
      @food = 'food'
    end

    def cacheable_widget_with_needs_keys
      @person = 'person'
      @food = 'food'
    end

    def cacheable_widget_with_skip_digest
    end

    def cacheable_widget_with_static_keys
    end
  end

  def test_action(action)
    @response = TestCachingController.action(action).call(Rack::MockRequest.env_for("/path"))[2]
    @response.body
  end

  def digestor_for(template_name)
    if Gem::Version.new(::Rails.version) > Gem::Version.new('4.0.0')
      ActionView::Digestor.new(name: "test_caching/#{template_name}.rb", finder: ActionController::Base.new.lookup_context)
    else
      ActionView::Digestor.new("test_caching/#{template_name}", :rb, ActionController::Base.new.lookup_context)
    end
  end

  context 'disabled in Rails config' do
    before do
      allow_any_instance_of(TestCachingController).to receive(:perform_caching).and_return(false)
    end

    it 'does not perform caching' do
      expect(DateTime).to receive(:current).exactly(2).times
      2.times { test_action(:cache_helper) }
    end
  end

  before(:each) do
    ::Rails.cache.clear
  end

  describe 'helpers.cache' do
    context 'for a template' do
      it 'calculates the fragment' do
        expect_any_instance_of(TestCachingController).to receive(:read_fragment).
          with(['cache_helper_key', 'bb530bfa0e2512415cc491ae2cb67b31'], nil)

        test_action(:cache_helper)
      end

      it 'caches properly' do
        expect(DateTime).to receive(:current).exactly(1).times
        2.times { test_action(:cache_helper) }
      end
    end

    context 'for a partial' do
      it 'calculates the fragment' do
        expect_any_instance_of(TestCachingController).to receive(:read_fragment).
          with(['cache_helper_with_partial_key', 'd344d73b7967f342b19f502ed75bf787'], nil)

        expect_any_instance_of(TestCachingController).to receive(:read_fragment).
          with(['partial_key', '50a64015c65ef2b37558333733245988'], nil)

        test_action(:cache_helper_with_partial)
      end

      it 'caches properly' do
        expect(DateTime).to receive(:current).exactly(2).times
        2.times { test_action(:cache_helper_with_partial) }
      end
    end

    it 'can skip the digest with skip_digest: true' do
      expect_any_instance_of(TestCachingController).to receive(:read_fragment).
        with('cache_helper_with_skip_digest_key', skip_digest: true)

      test_action(:cache_helper_with_skip_digest)
    end

    it 'honors implicit dependencies' do
      digestor = digestor_for(:cache_helper_with_implicit_dependencies)
      expect(digestor.dependencies).to eq ['test_caching/foos']
    end

    it 'honors explicit dependencies' do
      digestor = digestor_for(:cache_helper_with_explicit_dependencies)
      expect(digestor.dependencies).to eq ['test_caching/foos']
    end
  end

  describe 'Widget.cacheable' do
    it 'sets as cacheable' do
      expect(Views::TestCaching::CacheableWidgetWithNeeds.new(person: nil, food: nil)).to be_cacheable
    end

    context ':needs as cache key' do
      it 'calculates the fragment key' do
        expect_any_instance_of(ActionView::Base).to receive(:cache).
          with(['person', 'food'], skip_digest: nil)

        test_action(:cacheable_widget_with_needs)
      end
    end

    it 'can select using the :needs_keys option' do
      expect_any_instance_of(ActionView::Base).to receive(:cache).
        with(['person', 'beer'], skip_digest: nil)

      test_action(:cacheable_widget_with_needs_keys)
    end

    it 'can skip the digest with skip_digest: true' do
      expect_any_instance_of(ActionView::Base).to receive(:cache).
        with([], skip_digest: true)

      test_action(:cacheable_widget_with_skip_digest)
    end

    it 'can add static keys' do
      expect_any_instance_of(ActionView::Base).to receive(:cache).
        with(['v1'], skip_digest: nil)

      test_action(:cacheable_widget_with_static_keys)
    end

    it 'caches appropriately' do
      expect(DateTime).to receive(:current).exactly(1).times
      2.times { test_action(:cacheable_widget_with_static_keys) }
    end

    it 'does not cache when called without rails helpers' do
      expect(DateTime).to receive(:current).exactly(2).times
      2.times do
        Views::TestCaching::CacheableWidgetWithStaticKeys.new.to_html
      end
    end

  end

end
