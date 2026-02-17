# frozen_string_literal: true

require "tly/url_shortener_api/version"
require "tly/url_shortener_api/errors"
require "tly/url_shortener_api/response"
require "tly/url_shortener_api/client"

module Tly
  module UrlShortenerApi
    class << self
      def client(api_token:, **options)
        Client.new(api_token: api_token, **options)
      end
    end
  end
end
