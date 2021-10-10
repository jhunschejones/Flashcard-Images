module Clients
  class Pixabay < ImageClient
    PAGE_NUMBER = 1.freeze
    PER_PAGE_RESULT_COUNT = 60.freeze
    PIXABAY_PROVIDER = "pixabay".freeze

    class << self
      def search(query, page: PAGE_NUMBER, result_count: PER_PAGE_RESULT_COUNT)
        Rails.cache.fetch("query:#{query}:provider:#{PIXABAY_PROVIDER}:page:#{page}:result_count:#{result_count}") do
          time_client_response(client: PIXABAY_PROVIDER, query: query) do
            ::Pixabay.new
              .photos(q: query, page: page, per_page: result_count).fetch("hits", [])
              .map do |image|
                ImageSearchResult.new(
                  url: image["webformatURL"],
                  alt: image["tags"]
                )
              end
          end
        end
      end
    end
  end
end
