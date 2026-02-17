# frozen_string_literal: true

module Tly
  module UrlShortenerApi
    class Response
      attr_reader :status, :headers, :body, :raw_body

      def initialize(status:, headers:, body:, raw_body:)
        @status = status
        @headers = headers
        @body = body
        @raw_body = raw_body
      end

      def success?
        (200..299).cover?(status)
      end
    end
  end
end
