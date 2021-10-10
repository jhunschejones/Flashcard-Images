require 'test_helper'

# bundle exec ruby -Itest test/lib/clients/pexels_test.rb
class Clients::PexelsTest < ActiveSupport::TestCase
  before do
    VCR.insert_cassette(
      "pexels_test_#{self.class}_#{name}",
      { match_requests_on: [:method, :path] }
    )
  end

  after do
    VCR.eject_cassette
  end

  describe ".search" do
    it "returns expected number of images" do
      results = Clients::Pexels.search("cats")
      expected_size = Clients::Pexels::PER_PAGE_RESULT_COUNT

      assert_equal expected_size, results.size
    end

    it "returns urls and alts for all images" do
      results = Clients::Pexels.search("cats")
      expected_size = Clients::Pexels::PER_PAGE_RESULT_COUNT

      assert_equal expected_size, results.map(&:url).compact.size
      assert_equal expected_size, results.map(&:alt).compact.size
    end

    it "caches results with expected key" do
      cache = Rails.cache
      cache_key = "query:cats:provider:#{Clients::Pexels::PEXELS_PROVIDER}:page:#{Clients::Pexels::PAGE_NUMBER}:result_count:#{Clients::Pexels::PER_PAGE_RESULT_COUNT}:locale:#{Clients::Pexels::LOCALE}"
      Rails.expects(:cache).once.returns(cache)
      cache.expects(:fetch).once.with(cache_key).returns([])

      Clients::Pexels.search("cats")
    end

    it "reports client request time to new relic" do
      NewRelic::Agent.expects(:record_custom_event)
      Clients::Pexels.search("cats")
    end
  end
end
