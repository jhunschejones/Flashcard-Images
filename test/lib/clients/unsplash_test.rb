require 'test_helper'

# bundle exec ruby -Itest test/lib/clients/unsplash_test.rb
class Clients::UnsplashTest < ActiveSupport::TestCase
  describe ".search" do
    it "returns expected number of images" do
      results = Clients::Unsplash.search("cats")
      expected_size = Clients::Unsplash::PER_PAGE_RESULT_COUNT

      assert_equal expected_size, results.size
    end

    it "returns urls and alts for all images" do
      results = Clients::Unsplash.search("cats")
      expected_size = Clients::Unsplash::PER_PAGE_RESULT_COUNT

      assert_equal expected_size, results.map(&:url).compact.size
      assert_equal expected_size, results.map(&:alt).compact.size
    end

    it "caches results with expected key" do
      cache = Rails.cache
      cache_key = "query:cats:provider:#{Clients::Unsplash::UNSPLASH_PROVIDER}:page:#{Clients::Unsplash::PAGE_NUMBER}:result_count:#{Clients::Unsplash::PER_PAGE_RESULT_COUNT}"
      Rails.expects(:cache).once.returns(cache)
      cache.expects(:fetch).once.with(cache_key).returns([])

      Clients::Unsplash.search("cats")
    end

    it "reports client request time to new relic" do
      NewRelic::Agent.expects(:record_custom_event)
      Clients::Unsplash.search("cats")
    end
  end
end
