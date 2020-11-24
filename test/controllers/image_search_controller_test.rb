require 'test_helper'

# bundle exec ruby -Itest test/controllers/sessions_controller_test.rb
class ImageSearchControllerTest < ActionDispatch::IntegrationTest
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
          Unsplash::Photo.expects(:search).never
          Pixabay.expects(:new).never
          Pexels::Client.expects(:new).never
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

        it "only queries unsplash" do
          Unsplash::Photo.expects(:search).once.returns([])
          Pixabay.expects(:new).never
          Pexels::Client.expects(:new).never
          get search_path(q: "cats", provider: "unsplash")
        end

        describe "when no results are found" do
          it "shows empty results and expected flash message" do
            no_results_search_term = SecureRandom.uuid
            expected_message = "Unsplash didn't have any images for '#{no_results_search_term}'"

            get search_path(q: no_results_search_term, provider: "unsplash")

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

        it "only queries pixabay" do
          pixabay_provider = Pixabay.new
          Pixabay.expects(:new).once.returns(pixabay_provider)
          Unsplash::Photo.expects(:search).never
          Pexels::Client.expects(:new).never
          get search_path(q: "cats", provider: "pixabay")
        end

        describe "when no results are found" do
          it "shows empty results and expected flash message" do
            no_results_search_term = SecureRandom.uuid
            expected_message = "Pixabay didn't have any images for '#{no_results_search_term}'"

            get search_path(q: no_results_search_term, provider: "pixabay")

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

        it "only queries pexels" do
          pexels_provider = Pexels::Client.new
          Pexels::Client.expects(:new).once.returns(pexels_provider)
          Pixabay.expects(:new).never
          Unsplash::Photo.expects(:search).never
          get search_path(q: "cats", provider: "pexels")
        end

        describe "when no results are found" do
          it "shows empty results and expected flash message" do
            no_results_search_term = SecureRandom.uuid
            expected_message = "Pexels didn't have any images for '#{no_results_search_term}'"

            get search_path(q: no_results_search_term, provider: "pexels")

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
          assert_select "img.image-result", count: 150
        end

        it "queries all providers" do
          pixabay_provider = Pixabay.new
          pexels_provider = Pexels::Client.new
          Pexels::Client.expects(:new).once.returns(pexels_provider)
          Pixabay.expects(:new).once.returns(pixabay_provider)
          Unsplash::Photo.expects(:search).once.returns([])
          get search_path(q: "cats", provider: "multi")
        end

        describe "when no results are found" do
          it "shows empty results and expected flash message" do
            no_results_search_term = SecureRandom.uuid
            expected_message = "No availible providers had any images for '#{no_results_search_term}'"

            get search_path(q: no_results_search_term, provider: "multi")

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
          assert_select "img.image-result", count: 150
        end

        it "queries all providers" do
          pixabay_provider = Pixabay.new
          pexels_provider = Pexels::Client.new
          Pexels::Client.expects(:new).once.returns(pexels_provider)
          Pixabay.expects(:new).once.returns(pixabay_provider)
          Unsplash::Photo.expects(:search).once.returns([])
          get search_path(q: "cats")
        end

        describe "when no results are found" do
          it "shows empty results and expected flash message" do
            no_results_search_term = SecureRandom.uuid
            expected_message = "No availible providers had any images for '#{no_results_search_term}'"

            get search_path(q: no_results_search_term)

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
          Unsplash::Photo.expects(:search).never
          Pexels::Client.expects(:new).never
          get search_path(q: "cats", provider: "space_cats")
        end
      end
    end
  end
end
