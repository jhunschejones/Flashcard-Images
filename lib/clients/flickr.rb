module Clients
  class Flickr < ImageClient
    BASE_URI = "https://www.flickr.com/services/rest/".freeze
    JSON_HEADERS = { "Content-Type" => "application/json", "Accept" => "application/json" }.freeze
    PAGE_NUMBER = 1.freeze
    PER_PAGE_RESULT_COUNT = 60.freeze
    FLICKR_PROVIDER = "flickr".freeze

    class << self
      def search(query, page: PAGE_NUMBER, result_count: PER_PAGE_RESULT_COUNT)
        Rails.cache.fetch("query:#{query}:provider:#{FLICKR_PROVIDER}:page:#{page}:result_count:#{result_count}") do
          time_client_response(client: FLICKR_PROVIDER, query: query) do
            if ENV["USE_FLICKR_GEM"]
              # Flickr photo search docs: https://www.flickr.com/services/api/flickr.photos.search.html
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
            else
              # Docs: https://www.flickr.com/services/api/explore/flickr.photos.search
              query_params = {
                format: "json",
                nojsoncallback: 1,
                method: "flickr.photos.search",
                text: query,
                page: page,
                per_page: result_count,
                content_type: 1,
                sort: "relevance",
                media: "photos",
                is_getty: "true",
                safe_search: 3,
              }.merge(oauth_params)

              response = HTTParty.get(
                BASE_URI,
                headers: JSON_HEADERS,
                query: query_params.merge({oauth_signature: sign(query_params)})
              )
              JSON.parse(response.body)["photos"]["photo"].map do |image|
                ImageSearchResult.new(
                  # Building an image URL https://www.flickr.com/services/api/misc.urls.html
                  url: "https://live.staticflickr.com/#{image["server"]}/#{image["id"]}_#{image["secret"]}_z.jpg",
                  alt: image["title"]
                )
              end
            end
          end
        end
      end

      private

      # Docs: https://www.flickr.com/services/api/auth.oauth.html
      def oauth_params
        {
          oauth_nonce: [OpenSSL::Random.random_bytes(32)].pack("m0").gsub(/\n$/,""),
          oauth_timestamp: Time.now.to_i,
          oauth_consumer_key: ENV["FLICKR_API_KEY"],
          oauth_token: ENV["FLICKR_ACCESS_TOKEN"],
          oauth_signature_method: "HMAC-SHA1",
        }
      end

      # Adapted from https://github.com/cyclotron3k/flickr/blob/master/lib/flickr/oauth_client.rb
      def sign(query_params)
        text = signature_base_string(query_params, "get", BASE_URI)
        key = "#{ENV["FLICKR_SHARED_SECRET"]}&#{ENV["FLICKR_ACCESS_SECRET"]}"
        digest = OpenSSL::Digest::SHA1.new
        [OpenSSL::HMAC.digest(digest, key, text)].pack("m0").gsub(/\n$/,"")
      end

      # Adapted from https://github.com/cyclotron3k/flickr/blob/master/lib/flickr/oauth_client.rb
      def signature_base_string(params, method, url)
        params_norm = params.map { |k, v| "#{escape(k.to_s)}=#{escape(v.to_s)}" }.sort.join("&")
        "#{method.to_s.upcase}&#{escape(url)}&#{escape(params_norm)}"
      end

      # Adapted from https://github.com/cyclotron3k/flickr/blob/master/lib/flickr/oauth_client.rb
      def escape(string)
        string.gsub(/[^a-zA-Z0-9\-\.\_\~]/) do |special|
          special.unpack("C*").map { |i| sprintf("%%%02X", i) }.join
        end
      end
    end
  end
end
