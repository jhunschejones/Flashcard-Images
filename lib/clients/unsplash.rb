module Clients
  class Unsplash < ImageClient
    PAGE_NUMBER = 1
    PER_PAGE_RESULT_COUNT = 30 # max allowed by unsplash API
    UNSPLASH_PROVIDER = "unsplash".freeze

    JSON_HEADERS = { "Content-Type" => "application/json", "Accept" => "application/json" }.freeze
    BASE_URI = "https://api.unsplash.com/search/photos".freeze

    class << self
      def search(query, page: PAGE_NUMBER, result_count: PER_PAGE_RESULT_COUNT)
        Rails.cache.fetch("query:#{query}:provider:#{UNSPLASH_PROVIDER}:page:#{page}:result_count:#{result_count}") do
          time_client_response(client: UNSPLASH_PROVIDER, query: query) do
            query_params = {
              query: query,
              page: page,
              per_page: result_count
            }
            response = HTTParty.get(
              BASE_URI,
              headers: JSON_HEADERS.merge({
                "Accept-Version" => "v1",
                "Authorization" => "Client-ID #{ENV["UNSPLASH_ACCESS_KEY"]}"
              }),
              query: query_params
            )
            JSON.parse(response.body).fetch("results", []).map do |image|
              ImageSearchResult.new(
                url: image["urls"]["small"].gsub("w=400", "h=400"),
                alt: image["description"] || image["alt_description"]
              )
            end
          end
        end
      end
    end
  end
end
