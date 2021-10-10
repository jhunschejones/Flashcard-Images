require 'test_helper'

# bundle exec ruby -Itest test/controllers/image_search_controller_test.rb
class ImageSearchControllerTest < ActionDispatch::IntegrationTest
  NO_RESULTS_SEARCH_TERM = "vvgecievugufukukdhdifljfcfnltjbgfnvtgjvhillt".freeze

  before do
    VCR.insert_cassette(
      "image_search_controller_test_#{self.class}_#{name}",
      { match_requests_on: [:method, :path] }
    )
  end

  after do
    VCR.eject_cassette
  end

  describe "GET search" do
    describe "when no user is logged in" do
      it "redirects to the login page" do
        get search_path
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      describe "when no query is specified" do
        it "shows the search page with no results or warnings" do
          get search_path
          assert_response :success
          assert_select "div.index-container"
          assert_select "img.image-result", count: 0
          assert_nil flash[:notice]
        end

        it "doesnt query any image providers" do
          Clients::Unsplash.expects(:search).never
          Pixabay.expects(:new).never
          Pexels::Client.expects(:new).never
          Clients::Flickr.expects(:search).never
          Clients::Shutterstock.expects(:search).never
          get search_path
        end
      end

      describe "when unsplash provider is specified" do
        it "shows the serach page with image results" do
          get search_path(q: "cats", provider: "unsplash")
          assert_response :success
          assert_select "div.index-container"
          assert_select "img.image-result", count: 30
        end

        it "persists previous query and provider values" do
          get search_path(q: "cats", provider: "unsplash")
          assert_select "input.image-search-input" do
            assert_select "[value=?]", "cats"
          end
          assert_select "select#provider" do
            assert_select "[value=?]", "unsplash"
          end
        end

        it "only queries unsplash" do
          Clients::Unsplash.expects(:search).once.returns([])
          Pixabay.expects(:new).never
          Pexels::Client.expects(:new).never
          Clients::Flickr.expects(:search).never
          Clients::Shutterstock.expects(:search).never
          get search_path(q: "cats", provider: "unsplash")
        end

        describe "when no results are found" do
          it "shows empty results and expected flash message" do
            expected_message = "Unsplash didn't have any images for '#{NO_RESULTS_SEARCH_TERM}'"
            get search_path(q: NO_RESULTS_SEARCH_TERM, provider: "unsplash")

            assert_response :success
            assert_select "div.index-container"
            assert_select "img.image-result", count: 0
            assert_equal expected_message, flash[:notice]
          end
        end
      end

      describe "when pixabay provider is specified" do
        it "shows the serach page with image results" do
          get search_path(q: "cats", provider: "pixabay")
          assert_response :success
          assert_select "div.index-container"
          assert_select "img.image-result", count: 60
        end

        it "persists previous query and provider values" do
          get search_path(q: "cats", provider: "pixabay")
          assert_select "input.image-search-input" do
            assert_select "[value=?]", "cats"
          end
          assert_select "select#provider" do
            assert_select "[value=?]", "pixabay"
          end
        end

        it "only queries pixabay" do
          pixabay_provider = Pixabay.new

          Clients::Unsplash.expects(:search).never
          Pixabay.expects(:new).once.returns(pixabay_provider)
          Pexels::Client.expects(:new).never
          Clients::Flickr.expects(:search).never
          Clients::Shutterstock.expects(:search).never

          get search_path(q: "cats", provider: "pixabay")
        end

        describe "when no results are found" do
          it "shows empty results and expected flash message" do
            expected_message = "Pixabay didn't have any images for '#{NO_RESULTS_SEARCH_TERM}'"
            get search_path(q: NO_RESULTS_SEARCH_TERM, provider: "pixabay")

            assert_response :success
            assert_select "div.index-container"
            assert_select "img.image-result", count: 0
            assert_equal expected_message, flash[:notice]
          end
        end
      end

      describe "when pexels provider is specified" do
        it "shows the serach page with image results" do
          get search_path(q: "cats", provider: "pexels")
          assert_response :success
          assert_select "div.index-container"
          assert_select "img.image-result", count: 60
        end

        it "persists previous query and provider values" do
          get search_path(q: "cats", provider: "pexels")
          assert_select "input.image-search-input" do
            assert_select "[value=?]", "cats"
          end
          assert_select "select#provider" do
            assert_select "[value=?]", "pexels"
          end
        end

        it "only queries pexels" do
          pexels_provider = Pexels::Client.new

          Clients::Unsplash.expects(:search).never
          Pixabay.expects(:new).never
          Pexels::Client.expects(:new).once.returns(pexels_provider)
          Clients::Flickr.expects(:search).never
          Clients::Shutterstock.expects(:search).never

          get search_path(q: "cats", provider: "pexels")
        end

        describe "when no results are found" do
          it "shows empty results and expected flash message" do
            expected_message = "Pexels didn't have any images for '#{NO_RESULTS_SEARCH_TERM}'"
            get search_path(q: NO_RESULTS_SEARCH_TERM, provider: "pexels")

            assert_response :success
            assert_select "div.index-container"
            assert_select "img.image-result", count: 0
            assert_equal expected_message, flash[:notice]
          end
        end
      end

      describe "when flickr provider is specified" do
        it "shows the serach page with image results" do
          get search_path(q: "cats", provider: "flickr")
          assert_response :success
          assert_select "div.index-container"
          assert_select "img.image-result", count: 60
        end

        it "persists previous query and provider values" do
          get search_path(q: "cats", provider: "flickr")
          assert_select "input.image-search-input" do
            assert_select "[value=?]", "cats"
          end
          assert_select "select#provider" do
            assert_select "[value=?]", "flickr"
          end
        end

        it "only queries flickr" do
          Clients::Unsplash.expects(:search).never
          Pixabay.expects(:new).never
          Pexels::Client.expects(:new).never
          Clients::Flickr.expects(:search).once.returns([])
          Clients::Shutterstock.expects(:search).never

          get search_path(q: "cats", provider: "flickr")
        end

        describe "when no results are found" do
          it "shows empty results and expected flash message" do
            expected_message = "Flickr didn't have any images for '#{NO_RESULTS_SEARCH_TERM}'"
            get search_path(q: NO_RESULTS_SEARCH_TERM, provider: "flickr")

            assert_response :success
            assert_select "div.index-container"
            assert_select "img.image-result", count: 0
            assert_equal expected_message, flash[:notice]
          end
        end
      end

      describe "when shutterstock provider is specified" do
        it "shows the serach page with image results" do
          get search_path(q: "cats", provider: "shutterstock")
          assert_response :success
          assert_select "div.index-container"
          assert_select "img.image-result", count: 60
        end

        it "persists previous query and provider values" do
          get search_path(q: "cats", provider: "shutterstock")
          assert_select "input.image-search-input" do
            assert_select "[value=?]", "cats"
          end
          assert_select "select#provider" do
            assert_select "[value=?]", "flickr"
          end
        end

        it "only queries shutterstock" do
          Clients::Unsplash.expects(:search).never
          Pixabay.expects(:new).never
          Pexels::Client.expects(:new).never
          Clients::Flickr.expects(:search).never
          Clients::Shutterstock.expects(:search).once.returns([])

          get search_path(q: "cats", provider: "shutterstock")
        end

        describe "when no results are found" do
          it "shows empty results and expected flash message" do
            expected_message = "Shutterstock didn't have any images for '#{NO_RESULTS_SEARCH_TERM}'"
            get search_path(q: NO_RESULTS_SEARCH_TERM, provider: "shutterstock")

            assert_response :success
            assert_select "div.index-container"
            assert_select "img.image-result", count: 0
            assert_equal expected_message, flash[:notice]
          end
        end
      end

      describe "when multi provider is specified" do
        it "shows the serach page with image results" do
          get search_path(q: "cats", provider: "multi")
          assert_response :success
          assert_select "div.index-container"
          assert_select "img.image-result", count: 270
        end

        it "persists previous query and provider values" do
          get search_path(q: "cats", provider: "multi")
          assert_select "input.image-search-input" do
            assert_select "[value=?]", "cats"
          end
          assert_select "select#provider" do
            assert_select "[value=?]", "multi"
          end
        end

        it "queries the intended providers" do
          pixabay_provider = Pixabay.new
          pexels_provider = Pexels::Client.new

          Clients::Unsplash.expects(:search).once.returns([])
          Pixabay.expects(:new).once.returns(pixabay_provider)
          Pexels::Client.expects(:new).once.returns(pexels_provider)
          Clients::Flickr.expects(:search).once.returns([])
          Clients::Shutterstock.expects(:search).once.returns([])

          get search_path(q: "cats", provider: "multi")
        end

        describe "when no results are found" do
          it "shows empty results and expected flash message" do
            expected_message = "No availible providers had any images for '#{NO_RESULTS_SEARCH_TERM}'"
            get search_path(q: NO_RESULTS_SEARCH_TERM, provider: "multi")

            assert_response :success
            assert_select "div.index-container"
            assert_select "img.image-result", count: 0
            assert_equal expected_message, flash[:notice]
          end
        end
      end

      describe "when no provider is specified" do
        it "shows the serach page with image results" do
          get search_path(q: "cats")
          assert_response :success
          assert_select "div.index-container"
          assert_select "img.image-result", count: 270
        end

        it "persists previous query and provider values" do
          get search_path(q: "cats")
          assert_select "input.image-search-input" do
            assert_select "[value=?]", "cats"
          end
          assert_select "select#provider" do
            assert_select "[value=?]", ImageSearchController::DEFAULT_PROVIDER
          end
        end

        it "queries the intended providers" do
          pixabay_provider = Pixabay.new
          pexels_provider = Pexels::Client.new

          Clients::Unsplash.expects(:search).once.returns([])
          Pixabay.expects(:new).once.returns(pixabay_provider)
          Pexels::Client.expects(:new).once.returns(pexels_provider)
          Clients::Flickr.expects(:search).once.returns([])
          Clients::Shutterstock.expects(:search).once.returns([])

          get search_path(q: "cats")
        end

        describe "when no results are found" do
          it "shows empty results and expected flash message" do
            expected_message = "No availible providers had any images for '#{NO_RESULTS_SEARCH_TERM}'"
            get search_path(q: NO_RESULTS_SEARCH_TERM)

            assert_response :success
            assert_select "div.index-container"
            assert_select "img.image-result", count: 0
            assert_equal expected_message, flash[:notice]
          end
        end
      end

      describe "when an invalid provider is specified" do
        it "shows the search page with a message" do
          get search_path(q: "cats", provider: "space_cats")
          assert_equal "Unrecognized provider 'space_cats'", flash[:alert]
        end

        it "does not query any providers" do
          Pixabay.expects(:new).never
          Clients::Unsplash.expects(:search).never
          Pexels::Client.expects(:new).never
          Clients::Flickr.expects(:search).never
          Clients::Shutterstock.expects(:search).never

          get search_path(q: "cats", provider: "space_cats")
        end
      end
    end
  end
end
