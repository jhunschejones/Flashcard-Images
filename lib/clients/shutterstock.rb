module Clients
  class Shutterstock < ImageClient
    PAGE_NUMBER = 1.freeze
    PER_PAGE_RESULT_COUNT = 60.freeze
    SHUTTERSTOCK_PROVIDER = "shutterstock".freeze
    REGION = "ja".freeze

    class << self
      def search(query, page: PAGE_NUMBER, result_count: PER_PAGE_RESULT_COUNT, region: REGION)
        Rails.cache.fetch("query:#{query}:provider:#{SHUTTERSTOCK_PROVIDER}:page:#{page}:result_count:#{result_count}:region:#{region}") do
          time_client_response(client: SHUTTERSTOCK_PROVIDER, query: query) do
            response = HTTParty.get(
              "https://api.shutterstock.com/v2/images/search",
              headers: {
                "Content-Type" => "application/json",
                "Accept" => "application/json",
                "Authorization" => "Bearer #{ENV["SHUTTERSTOCK_TOKEN"]}",
              },
              # https://api-reference.shutterstock.com/#images-search-for-images
              query: {
                page: page,
                per_page: result_count,
                query: query,
                sort: "relevance",
                region: region,
                keyword_safe_search: "false",
                safe: "false",
              }
            )
            JSON.parse(response.body).fetch("data", []).map do |image|
              ImageSearchResult.new(
                url: image["assets"]["preview_1000"]["url"],
                alt: image["description"]
              )
            end
          end
        end
      end
    end
  end
end
