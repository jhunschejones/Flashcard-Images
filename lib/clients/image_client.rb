module Clients
  class ImageClient
    CLIENT_REQUEST_TIME_EVENT = "ImageClientRequestTime".freeze

    class << self
      def search
        raise "Not implemented"
      end

      protected

      def time_client_response(client:, query:)
        start_time = time_in_millis_now
        return_value = yield
        ::NewRelic::Agent.record_custom_event(
          CLIENT_REQUEST_TIME_EVENT,
          client: client,
          query: query,
          client_request_time: time_in_millis_now - start_time
        )
        return_value
      end

      def time_in_millis_now
        (Time.now.to_f * 1000).to_i
      end
    end
  end
end
