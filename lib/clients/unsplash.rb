module Clients
  class Unsplash
    PAGE_NUMBER = 1.freeze
    PER_PAGE_RESULT_COUNT = 30.freeze # max allowed by unsplash API

    class << self
      def search(query, page: PAGE_NUMBER, result_count: PER_PAGE_RESULT_COUNT)
        ::Unsplash::Photo
          .search(query, page, result_count)
          .map do |image|
            ImageSearchResult.new(
              image.urls["small"].gsub("w=400", "h=400"),
              image.description
            )
          end
      end
    end
  end
end
