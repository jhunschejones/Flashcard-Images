module Clients
  class Pexels < ImageClient
    PAGE_NUMBER = 1
    PER_PAGE_RESULT_COUNT = 60
    # This local returns the same results as en-US when searching in english,
    # but better results when searching in japanese.
    LOCALE = "ja-JP".freeze
    PEXELS_PROVIDER = "pexels".freeze

    class << self
      def search(query, page: PAGE_NUMBER, result_count: PER_PAGE_RESULT_COUNT, locale: LOCALE)
        Rails.cache.fetch("query:#{query}:provider:#{PEXELS_PROVIDER}:page:#{page}:result_count:#{result_count}:locale:#{locale}") do
          time_client_response(client: PEXELS_PROVIDER, query: query) do
            (::Pexels::Client.new.photos
              .search(query, page: page, per_page: result_count, locale: locale)
              .photos || [])
              .map do |image|
                ImageSearchResult.new(
                  url: image.src["medium"].gsub("h=350", "h=400"),
                  alt: image.src["original"].scan(/\/photos\/\d+\/(.*)\..*/).flatten.first
                )
              end
          end
        end
      end
    end
  end
end
