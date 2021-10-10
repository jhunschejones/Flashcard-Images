require 'test_helper'

# bundle exec ruby -Itest test/lib/clients/shutterstock_test.rb
class Clients::ShutterstockTest < ActiveSupport::TestCase
  before do
    VCR.insert_cassette(
      "shutterstock_test_#{self.class}_#{name}",
      { match_requests_on: [:method, :path] }
    )
  end

  after do
    VCR.eject_cassette
  end

  describe ".search" do
    it "returns expected number of images" do
      results = Clients::Shutterstock.search("cats")
      expected_size = Clients::Shutterstock::PER_PAGE_RESULT_COUNT

      assert_equal expected_size, results.size
    end

    it "returns urls and alts for all images" do
      results = Clients::Shutterstock.search("cats")
      expected_size = Clients::Shutterstock::PER_PAGE_RESULT_COUNT

      assert_equal expected_size, results.map(&:url).compact.size
      assert_equal expected_size, results.map(&:alt).compact.size
    end

    it "caches results with expected key" do
      cache = Rails.cache
      cache_key = "query:cats:provider:#{Clients::Shutterstock::SHUTTERSTOCK_PROVIDER}:page:#{Clients::Shutterstock::PAGE_NUMBER}:result_count:#{Clients::Shutterstock::PER_PAGE_RESULT_COUNT}:region:#{Clients::Shutterstock::REGION}"
      Rails.expects(:cache).once.returns(cache)
      cache.expects(:fetch).once.with(cache_key).returns([])

      Clients::Shutterstock.search("cats")
    end

    it "reports client request time to new relic" do
      NewRelic::Agent.expects(:record_custom_event)
      Clients::Shutterstock.search("cats")
    end
  end
end
