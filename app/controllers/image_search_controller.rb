class ImageSearchController < ApplicationController
  class UnrecognizedProvider < StandardError; end
  MULTI_PROVIDER = "multi".freeze
  DEFAULT_PROVIDER = MULTI_PROVIDER.freeze
  PROVIDER_OPTIONS = {
    "Multi" => "multi",
    "Unsplash" => "unsplash",
    "Pixabay" => "pixabay",
    "Pexels" => "pexels",
    "Flickr" => "flickr",
    "Shutterstock" => "shutterstock"
  }.freeze

  def search
    @provider = params[:provider]&.strip&.downcase || DEFAULT_PROVIDER
    @query = params[:q]&.strip&.downcase
    NewRelic::Agent.add_custom_attributes(provider: @provider, query: @query, user_id: @current_user.id)
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
      when Clients::Flickr::FLICKR_PROVIDER
        Clients::Flickr.search(@query)
      when Clients::Shutterstock::SHUTTERSTOCK_PROVIDER
        Clients::Shutterstock.search(@query)
      when MULTI_PROVIDER
        Thread.abort_on_exception = true
        [
          Thread.new { Clients::Unsplash.search(@query) },
          Thread.new { Clients::Pixabay.search(@query) },
          Thread.new { Clients::Pexels.search(@query) },
          Thread.new { Clients::Flickr.search(@query) },
          Thread.new { Clients::Shutterstock.search(@query) }
        ].flat_map(&:value)
      else
        raise UnrecognizedProvider, params[:provider].to_s
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
