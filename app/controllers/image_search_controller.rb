class ImageSearchController < ApplicationController
  PAGE_NUMBER = 1.freeze
  PER_PAGE_RESULT_COUNT = 30.freeze # max allowed by unsplash API
  UNSPLASH_PROVIDER = "unsplash".freeze

  def search
    @provider = params[:provider]&.strip&.downcase
    @previous_query = params[:q]&.strip&.downcase
    @images =
      if @previous_query.blank?
        []
      else
        Rails.cache.fetch("query:#{@previous_query}:provider:#{@provider}") do
          if @provider == UNSPLASH_PROVIDER
            Unsplash::Photo.search(@previous_query, PAGE_NUMBER, PER_PAGE_RESULT_COUNT)
          else
            Pixabay.new.photos(q: @previous_query, page: PAGE_NUMBER, per_page: PER_PAGE_RESULT_COUNT * 2)["hits"]
          end
        end
      end
    render :index
  end
end
