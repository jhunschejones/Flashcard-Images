require 'test_helper'

# bundle exec ruby -Itest test/lib/clients/pixabay_test.rb
class Clients::PixabayTest < ActiveSupport::TestCase
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
  end
end