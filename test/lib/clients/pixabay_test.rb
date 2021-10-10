require 'test_helper'

# bundle exec ruby -Itest test/lib/clients/pixabay_test.rb
class Clients::PixabayTest < ActiveSupport::TestCase
  before do
    VCR.insert_cassette(
      "pixabay_test_#{self.class}_#{name}",
      { match_requests_on: [:method, :path] }
    )
  end

  after do
    VCR.eject_cassette
  end

  describe ".search" do
    it "returns expected number of images" do
      results = Clients::Pixabay.search("cats")
      expected_size = Clients::Pixabay::PER_PAGE_RESULT_COUNT

      assert_equal expected_size, results.size
    end

    it "returns urls and alts for all images" do
      results = Clients::Pixabay.search("cats")
      expected_size = Clients::Pixabay::PER_PAGE_RESULT_COUNT

      assert_equal expected_size, results.map(&:url).compact.size
      assert_equal expected_size, results.map(&:alt).compact.size
    end

    it "caches results with expected key" do
      cache = Rails.cache
      cache_key = "query:cats:provider:#{Clients::Pixabay::PIXABAY_PROVIDER}:page:#{Clients::Pixabay::PAGE_NUMBER}:result_count:#{Clients::Pixabay::PER_PAGE_RESULT_COUNT}"
      Rails.expects(:cache).once.returns(cache)
      cache.expects(:fetch).once.with(cache_key).returns([])

      Clients::Pixabay.search("cats")
    end

    it "reports client request time to new relic" do
      NewRelic::Agent.expects(:record_custom_event)
      Clients::Pixabay.search("cats")
    end
  end
end
