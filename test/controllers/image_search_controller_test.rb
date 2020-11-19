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

      it "shows the search page with no results" do
        get search_path
        assert_response :success
        assert_select "div.index-container"
        assert_select "img.image-result", count: 0
      end

      it "doesnt query any image providers without query" do
        Unsplash::Photo.expects(:search).never
        Pixabay.expects(:new).never
        Pexels::Client.expects(:new).never
        get search_path
      end

      it "shows flash message when no results are found" do
        no_results_search_term = SecureRandom.uuid
        expected_message = "Pixabay didn't have any images for '#{no_results_search_term}'"

        get search_path(q: no_results_search_term, provider: "Pixabay")

        assert_response :success
        assert_select "div.index-container"
        assert_select "img.image-result", count: 0
        assert_equal expected_message, flash[:notice]
      end

      describe "when unsplash provider is specified" do
        it "shows the serach page with image results" do
          get search_path(q: "cats", provider: "Unsplash")
          assert_response :success
          assert_select "div.index-container"
          assert_select "img.image-result", count: 30
        end

        it "only queries unsplash" do
          Unsplash::Photo.expects(:search).once.returns([])
          Pixabay.expects(:new).never
          Pexels::Client.expects(:new).never
          get search_path(q: "cats", provider: "Unsplash")
        end
      end

      describe "when pixabay provider is specified" do
        it "shows the serach page with image results" do
          get search_path(q: "cats", provider: "Pixabay")
          assert_response :success
          assert_select "div.index-container"
          assert_select "img.image-result", count: 60
        end

        it "only queries pixabay" do
          pixabay_provider = Pixabay.new
          Pixabay.expects(:new).once.returns(pixabay_provider)
          Unsplash::Photo.expects(:search).never
          Pexels::Client.expects(:new).never
          get search_path(q: "cats", provider: "Pixabay")
        end
      end

      describe "when pixels provider is specified" do
        it "shows the serach page with image results" do
          get search_path(q: "cats", provider: "Pixels")
          assert_response :success
          assert_select "div.index-container"
          assert_select "img.image-result", count: 60
        end

        it "only queries pixels" do
          pixels_provider = Pexels::Client.new
          Pexels::Client.expects(:new).once.returns(pixels_provider)
          Pixabay.expects(:new).never
          Unsplash::Photo.expects(:search).never
          get search_path(q: "cats", provider: "Pixels")
        end
      end

      describe "when no provider is specified" do
        it "shows the serach page with image results" do
          get search_path(q: "cats")
          assert_response :success
          assert_select "div.index-container"
          assert_select "img.image-result", count: 60
        end

        it "only queries pixabay" do
          pixabay_provider = Pixabay.new
          Pixabay.expects(:new).once.returns(pixabay_provider)
          Unsplash::Photo.expects(:search).never
          Pexels::Client.expects(:new).never
          get search_path(q: "cats")
        end
      end

      describe "with a bad provider configured" do
        it "raises custom error" do
          assert_raise ImageSearchController::UnrecognizedProvider, "space_cats" do
            stub_const(ImageSearchController, "DEFAULT_PROVIDER", "space_cats") do
              get search_path(q: "cats")
            end
          end
        end

        it "does not query any real providers" do
          assert_raise do
            stub_const(ImageSearchController, "DEFAULT_PROVIDER", "space_cats") do
              Pixabay.expects(:new).never
              Unsplash::Photo.expects(:search).never
              Pexels::Client.expects(:new).never
              get search_path(q: "cats")
            end
          end
        end
      end
    end
  end
end
