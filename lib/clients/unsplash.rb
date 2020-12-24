module Clients
  class Unsplash < ImageClient
    PAGE_NUMBER = 1.freeze
    PER_PAGE_RESULT_COUNT = 30.freeze # max allowed by unsplash API
    UNSPLASH_PROVIDER = "unsplash".freeze

    class << self
      def search(query, page: PAGE_NUMBER, result_count: PER_PAGE_RESULT_COUNT)
        Rails.cache.fetch("query:#{query}:provider:#{UNSPLASH_PROVIDER}:page:#{page}:result_count:#{result_count}") do
          time_client_response(client: UNSPLASH_PROVIDER, query: query) do
            ::Unsplash::Photo
              .search(query, page, result_count)
              .map do |image|
                ImageSearchResult.new(
                  url: image.urls.small.gsub("w=400", "h=400"),
                  alt: (
                    image.description ||
                    image.tags&.first&.fetch("title") ||
                    image.urls.raw.scan(/images.unsplash.com\/(.+)\?/).flatten.first
                  )&.gsub("\n", "")&.strip
                )
              end
          end
        end
      end
    end
  end
end
