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
  end
end
