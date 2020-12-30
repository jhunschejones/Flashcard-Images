module Clients
  class Flickr < ImageClient
    PAGE_NUMBER = 1.freeze
    PER_PAGE_RESULT_COUNT = 60.freeze
    FLICKR_PROVIDER = "flickr".freeze

    class << self
      def search(query, page: PAGE_NUMBER, result_count: PER_PAGE_RESULT_COUNT)
        Rails.cache.fetch("query:#{query}:provider:#{FLICKR_PROVIDER}:page:#{page}:result_count:#{result_count}") do
          time_client_response(client: FLICKR_PROVIDER, query: query) do
            # Flickr photo search docs: https://www.flickr.com/services/api/flickr.photos.search.html
            # content_type: 1 is for photos only
            flickr = ::Flickr.new
            flickr.access_token = ENV["FLICKR_ACCESS_TOKEN"]
            flickr.access_secret = ENV["FLICKR_ACCESS_SECRET"]
            flickr.photos
              .search(
                text: query,
                page: page,
                per_page: result_count,
                content_type: 1,
                sort: "relevance",
                media: "photos",
                is_getty: "true",
                safe_search: 3
              ).map do |image|
                ImageSearchResult.new(
                  # Building a flickr URL https://www.flickr.com/services/api/misc.urls.html
                  url: "https://live.staticflickr.com/#{image["server"]}/#{image["id"]}_#{image["secret"]}_z.jpg",
                  alt: image["title"]
                )
              end
          end
        end
      end
    end
  end
end
