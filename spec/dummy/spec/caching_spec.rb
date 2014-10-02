require 'spec_helper'

describe 'Caching' do

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
  end

  def test_action(action)
    @response = TestCachingController.action(action).call(Rack::MockRequest.env_for("/path"))[2]
    @response.body
  end

  def digestor_for(template_name)
    ActionView::Digestor.new(name: "test_caching/#{template_name}.rb", finder: ActionController::Base.new.lookup_context)
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
    it 'uses :needs as the cache key'
    it 'can select using the :needs_keys option'
    it 'can skip the digest with skip_digest: true'
    it 'can add additional keys'
  end

end
