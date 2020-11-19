module Clients
  class Pixabay
    PAGE_NUMBER = 1.freeze
    PER_PAGE_RESULT_COUNT = 60.freeze

    class << self
      def search(query, page: PAGE_NUMBER, result_count: PER_PAGE_RESULT_COUNT)
        ::Pixabay.new
          .photos(q: query, page: page, per_page: result_count)["hits"]
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
