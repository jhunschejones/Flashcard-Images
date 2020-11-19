class ImageSearchController < ApplicationController
  class UnrecognizedProvider < StandardError; end

  UNSPLASH_PROVIDER = "unsplash".freeze
  PIXABAY_PROVIDER = "pixabay".freeze
  PEXELS_PROVIDER = "pexels".freeze
  DEFAULT_PROVIDER = PIXABAY_PROVIDER.freeze

  def search
    @provider = params[:provider]&.strip&.downcase || DEFAULT_PROVIDER
    @previous_query = params[:q]&.strip&.downcase

    if @previous_query.blank?
      @images = []
      return render :index
    end

    @images =
      Rails.cache.fetch("query:#{@previous_query}:provider:#{@provider}") do
        case @provider
        when UNSPLASH_PROVIDER
          Clients::Unsplash.search(@previous_query)
        when PIXABAY_PROVIDER
          Clients::Pixabay.search(@previous_query)
        when PEXELS_PROVIDER
          Clients::Pexels.search(@previous_query)
        else
          raise UnrecognizedProvider, "#{params[:provider]}"
        end
      end
    flash.now[:notice] = "#{@provider.titleize} didn't have any images for '#{@previous_query}'" if @images.blank?
    render :index
  end
end
