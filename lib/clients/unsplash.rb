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
