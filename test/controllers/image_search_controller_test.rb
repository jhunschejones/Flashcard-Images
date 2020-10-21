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

      it "doesnt query any image providers" do
        Unsplash::Photo.expects(:search).never
        Pixabay.expects(:new).never
        get search_path
      end

      describe "when unsplash provider is specified" do
        it "shows the serach page with image results" do
          get search_path(q: "cats", provider: "Unsplash")
          assert_response :success
          assert_select "div.index-container"
          assert_select "img.image-result", count: 30
        end

        it "only queries unsplash" do
          Pixabay.expects(:new).never
          Unsplash::Photo.expects(:search).once
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
          get search_path(q: "cats", provider: "Pixabay")
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
          get search_path(q: "cats")
        end
      end
    end
  end
end
