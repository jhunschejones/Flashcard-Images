class ImageSearchController < ApplicationController
  class UnrecognizedProvider < StandardError; end
  MULTI_PROVIDER = "multi".freeze
  DEFAULT_PROVIDER = MULTI_PROVIDER.freeze

  def search
    @provider = params[:provider]&.strip&.downcase || DEFAULT_PROVIDER
    @query = params[:q]&.strip&.downcase
    @images = []
    return render :index if @query.blank?

    @images =
      case @provider
      when Clients::Unsplash::UNSPLASH_PROVIDER
        Clients::Unsplash.search(@query)
      when Clients::Pixabay::PIXABAY_PROVIDER
        Clients::Pixabay.search(@query)
      when Clients::Pexels::PEXELS_PROVIDER
        Clients::Pexels.search(@query)
      when MULTI_PROVIDER
        Thread.abort_on_exception = true
        [
          Thread.new { Clients::Unsplash.search(@query) },
          Thread.new { Clients::Pixabay.search(@query) },
          Thread.new { Clients::Pexels.search(@query) }
        ].flat_map(&:value)
      else
        raise UnrecognizedProvider, "#{params[:provider]}"
      end
    flash.now[:notice] = "#{provider_message} any images for '#{@query}'" if @images.blank?
    render :index
  rescue UnrecognizedProvider
    flash.now[:alert] = "Unrecognized provider '#{params[:provider]}'"
    render :index
  end

  private

  def provider_message
    if @provider == MULTI_PROVIDER
      "No availible providers had"
    else
      "#{@provider.titleize} didn't have"
    end
  end
end
