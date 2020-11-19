module Clients
  class Pixels
    PAGE_NUMBER = 1.freeze
    PER_PAGE_RESULT_COUNT = 60.freeze
    # This local returns the same results as en-US when searching in english,
    # but better results when searching in japanese.
    LOCALE = "ja-JP".freeze

    class << self
      def search(query, page: PAGE_NUMBER, result_count: PER_PAGE_RESULT_COUNT, locale: LOCALE)
        ::Pexels::Client.new
          .photos
          .search(query, page: page, per_page: result_count, locale: locale)
          .photos
          .map do |image|
            ImageSearchResult.new(
              image.src["medium"].gsub("h=350", "h=400"),
              image.url.scan(/\/photo\/(.*)\//).first.first
            )
          end
      end
    end
  end
end
