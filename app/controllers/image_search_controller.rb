class ImageSearchController < ApplicationController
  class UnrecognizedProvider < StandardError; end
  MULTI_PROVIDER = "multi".freeze
  DEFAULT_PROVIDER = MULTI_PROVIDER.freeze

  def search
    @provider = params[:provider]&.strip&.downcase || DEFAULT_PROVIDER
    @previous_query = params[:q]&.strip&.downcase
    if @previous_query.blank?
      @images = []
      return render :index
    end

    @images =
      case @provider
      when Clients::Unsplash::UNSPLASH_PROVIDER
        Clients::Unsplash.search(@previous_query)
      when Clients::Pixabay::PIXABAY_PROVIDER
        Clients::Pixabay.search(@previous_query)
      when Clients::Pexels::PEXELS_PROVIDER
        Clients::Pexels.search(@previous_query)
      when MULTI_PROVIDER
        Clients::Unsplash.search(@previous_query) + Clients::Pixabay.search(@previous_query) + Clients::Pexels.search(@previous_query)
      else
        raise UnrecognizedProvider, "#{params[:provider]}"
      end
    flash.now[:notice] = "#{@provider.titleize} didn't have any images for '#{@previous_query}'" if @images.blank?
    render :index
  end
end
