class ImageSearchController < ApplicationController
  class UnrecognizedProvider < StandardError; end
  MULTI_PROVIDER = "multi".freeze
  DEFAULT_PROVIDER = MULTI_PROVIDER.freeze

  def search
    @provider = params[:provider]&.strip&.downcase || DEFAULT_PROVIDER
    @previous_query = params[:q]&.strip&.downcase
    @images = []
    return render :index if @previous_query.blank?

    @images =
      case @provider
      when Clients::Unsplash::UNSPLASH_PROVIDER
        Clients::Unsplash.search(@previous_query)
      when Clients::Pixabay::PIXABAY_PROVIDER
        Clients::Pixabay.search(@previous_query)
      when Clients::Pexels::PEXELS_PROVIDER
        Clients::Pexels.search(@previous_query)
      when MULTI_PROVIDER
        Thread.abort_on_exception = true
        [
          Thread.new { Clients::Unsplash.search(@previous_query) },
          Thread.new { Clients::Pixabay.search(@previous_query) },
          Thread.new { Clients::Pexels.search(@previous_query) }
        ].flat_map(&:value)
      else
        raise UnrecognizedProvider, "#{params[:provider]}"
      end
    flash.now[:notice] = "#{@provider.titleize} didn't have any images for '#{@previous_query}'" if @images.blank?
    render :index
  end
end
