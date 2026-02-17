# frozen_string_literal: true

module Tly
  module UrlShortenerApi
    class Error < StandardError
      attr_reader :status, :response_body, :headers

      def initialize(message = "T.LY API request failed", status: nil, response_body: nil, headers: nil)
        super(message)
        @status = status
        @response_body = response_body
        @headers = headers || {}
      end
    end

    class ClientError < Error; end
    class AuthenticationError < ClientError; end
    class PermissionError < ClientError; end
    class NotFoundError < ClientError; end
    class ValidationError < ClientError; end
    class RateLimitError < ClientError; end
    class ServerError < Error; end
    class TransportError < Error; end
  end
end
