# frozen_string_literal: true

require "cgi"
require "json"
require "net/http"
require "uri"

module Tly
  module UrlShortenerApi
    class Client
      DEFAULT_BASE_URL = "https://api.t.ly"

      attr_reader :api_token, :base_url, :open_timeout, :read_timeout, :user_agent

      def initialize(api_token:, base_url: DEFAULT_BASE_URL, open_timeout: 10, read_timeout: 30, user_agent: default_user_agent)
        token = api_token.to_s.strip
        raise ArgumentError, "api_token is required" if token.empty?

        @api_token = token
        @base_url = normalize_base_url(base_url)
        @open_timeout = open_timeout
        @read_timeout = read_timeout
        @user_agent = user_agent
      end

      # OneLink Stats Management
      def onelink_stats(short_url:, start_date: nil, end_date: nil)
        request(
          :get,
          "/api/v1/onelink/stats",
          query: { short_url: short_url, start_date: start_date, end_date: end_date }
        )
      end

      def delete_onelink_stats(short_url:)
        request(:delete, "/api/v1/onelink/stat", body: { short_url: short_url })
      end

      # ShortLink Management
      def shorten_link(long_url:, domain: nil, expire_at_datetime: nil, description: nil, public_stats: nil, meta: nil)
        request(
          :post,
          "/api/v1/link/shorten",
          body: {
            long_url: long_url,
            domain: domain,
            expire_at_datetime: expire_at_datetime,
            description: description,
            public_stats: public_stats,
            meta: meta
          }
        )
      end

      def get_link(short_url:)
        request(:get, "/api/v1/link", query: { short_url: short_url })
      end

      def update_link(short_url:, long_url: nil, expire_at_datetime: nil, description: nil, public_stats: nil, meta: nil)
        request(
          :put,
          "/api/v1/link",
          body: {
            short_url: short_url,
            long_url: long_url,
            expire_at_datetime: expire_at_datetime,
            description: description,
            public_stats: public_stats,
            meta: meta
          }
        )
      end

      def delete_link(short_url:)
        request(:delete, "/api/v1/link", body: { short_url: short_url })
      end

      def expand_link(short_url:, password: nil)
        request(:post, "/api/v1/link/expand", body: { short_url: short_url, password: password })
      end

      def list_links(search: nil, tag_ids: nil, pixel_ids: nil, start_date: nil, end_date: nil, domains: nil)
        request(
          :get,
          "/api/v1/link/list",
          query: {
            search: search,
            tag_ids: tag_ids,
            pixel_ids: pixel_ids,
            start_date: start_date,
            end_date: end_date,
            domains: domains
          }
        )
      end

      def bulk_shorten_links(links:, domain: nil, tags: nil, pixels: nil)
        request(
          :post,
          "/api/v1/link/bulk",
          body: {
            domain: domain,
            links: links,
            tags: tags,
            pixels: pixels
          }
        )
      end

      def bulk_update_links(links:, tags: nil, pixels: nil)
        request(
          :post,
          "/api/v1/link/bulk/update",
          body: {
            links: links,
            tags: tags,
            pixels: pixels
          }
        )
      end

      # ShortLink Stats
      def link_stats(short_url:, start_date: nil, end_date: nil)
        request(:get, "/api/v1/link/stats", query: { short_url: short_url, start_date: start_date, end_date: end_date })
      end

      # UTM Preset Management
      def create_utm_preset(name:, source:, medium:, campaign:, content: nil, term: nil)
        request(
          :post,
          "/api/v1/link/utm-preset",
          body: {
            name: name,
            source: source,
            medium: medium,
            campaign: campaign,
            content: content,
            term: term
          }
        )
      end

      def list_utm_presets
        request(:get, "/api/v1/link/utm-preset")
      end

      def get_utm_preset(id:)
        request(:get, path_with_id("/api/v1/link/utm-preset/:id", id))
      end

      def update_utm_preset(id:, name: nil, source: nil, medium: nil, campaign: nil, content: nil, term: nil)
        request(
          :put,
          path_with_id("/api/v1/link/utm-preset/:id", id),
          body: {
            name: name,
            source: source,
            medium: medium,
            campaign: campaign,
            content: content,
            term: term
          }
        )
      end

      def delete_utm_preset(id:)
        request(:delete, path_with_id("/api/v1/link/utm-preset/:id", id))
      end

      # OneLink Management
      def list_onelinks(page: nil)
        request(:get, "/api/v1/onelink/list", query: { page: page })
      end

      # Pixel Management
      def create_pixel(name:, pixel_id:, pixel_type:)
        request(:post, "/api/v1/link/pixel", body: { name: name, pixel_id: pixel_id, pixel_type: pixel_type })
      end

      def list_pixels
        request(:get, "/api/v1/link/pixel")
      end

      def get_pixel(id:)
        request(:get, path_with_id("/api/v1/link/pixel/:id", id))
      end

      def update_pixel(id:, name: nil, pixel_id: nil, pixel_type: nil)
        request(
          :put,
          path_with_id("/api/v1/link/pixel/:id", id),
          body: {
            id: id,
            name: name,
            pixel_id: pixel_id,
            pixel_type: pixel_type
          }
        )
      end

      def delete_pixel(id:)
        request(:delete, path_with_id("/api/v1/link/pixel/:id", id))
      end

      # QR Code Management
      def get_qr_code(short_url:, output: nil, format: nil)
        request(
          :get,
          "/api/v1/link/qr-code",
          query: {
            short_url: short_url,
            output: output,
            format: format
          }
        )
      end

      def update_qr_code(short_url:, image: nil, background_color: nil, corner_dots_color: nil, dots_color: nil,
                         dots_style: nil, corner_style: nil)
        request(
          :put,
          "/api/v1/link/qr-code",
          body: {
            short_url: short_url,
            image: image,
            background_color: background_color,
            corner_dots_color: corner_dots_color,
            dots_color: dots_color,
            dots_style: dots_style,
            corner_style: corner_style
          }
        )
      end

      # Tag Management
      def list_tags
        request(:get, "/api/v1/link/tag")
      end

      def create_tag(tag:)
        request(:post, "/api/v1/link/tag", body: { tag: tag })
      end

      def get_tag(id:)
        request(:get, path_with_id("/api/v1/link/tag/:id", id))
      end

      def update_tag(id:, tag:)
        request(:put, path_with_id("/api/v1/link/tag/:id", id), body: { tag: tag })
      end

      def delete_tag(id:)
        request(:delete, path_with_id("/api/v1/link/tag/:id", id))
      end

      # Low-level request for endpoints added in the future.
      def request(method, path, query: nil, body: nil, headers: {})
        uri = build_uri(path, query)

        req = build_request(method, uri)
        default_headers.each { |key, value| req[key] = value }
        headers.each { |key, value| req[key] = value }

        if body
          req["Content-Type"] ||= "application/json"
          req.body = JSON.generate(compact_payload(body))
        end

        response = execute_request(uri, req)
        raise_for_status!(response)
        response
      end

      private

      def default_user_agent
        "tly-url-shortener-api/#{Tly::UrlShortenerApi::VERSION}"
      end

      def normalize_base_url(url)
        normalized = url.to_s.strip.sub(%r{/+\z}, "")
        raise ArgumentError, "base_url is required" if normalized.empty?

        uri = URI.parse(normalized)
        return normalized if uri.is_a?(URI::HTTP) && uri.host

        raise ArgumentError, "base_url must be an absolute HTTP(S) URL"
      rescue URI::InvalidURIError => e
        raise ArgumentError, "base_url must be a valid URL: #{e.message}"
      end

      def default_headers
        {
          "Authorization" => "Bearer #{api_token}",
          "Accept" => "application/json",
          "User-Agent" => user_agent
        }
      end

      def build_request(method, uri)
        klass = {
          get: Net::HTTP::Get,
          post: Net::HTTP::Post,
          put: Net::HTTP::Put,
          patch: Net::HTTP::Patch,
          delete: Net::HTTP::Delete
        }[method.to_sym]

        raise ArgumentError, "Unsupported HTTP method: #{method}" unless klass

        klass.new(uri)
      end

      def execute_request(uri, request)
        raw_response = Net::HTTP.start(
          uri.host,
          uri.port,
          use_ssl: uri.scheme == "https",
          open_timeout: open_timeout,
          read_timeout: read_timeout
        ) do |http|
          http.request(request)
        end

        parsed = parse_response_body(raw_response)

        Response.new(
          status: raw_response.code.to_i,
          headers: normalize_headers(raw_response),
          body: parsed,
          raw_body: raw_response.body.to_s
        )
      rescue IOError, EOFError, SocketError, SystemCallError, Timeout::Error => e
        raise TransportError.new("T.LY API transport error: #{e.message}")
      end

      def parse_response_body(raw_response)
        raw_body = raw_response.body.to_s
        content_type = raw_response["Content-Type"].to_s.downcase

        return raw_body unless content_type.include?("json")

        JSON.parse(raw_body)
      rescue JSON::ParserError
        raw_body
      end

      def normalize_headers(raw_response)
        raw_response.each_header.each_with_object({}) do |(key, value), headers|
          headers[key.downcase] = value
        end
      end

      def raise_for_status!(response)
        return if response.success?

        message = extract_error_message(response)
        klass = error_class_for(response.status)
        raise klass.new(message, status: response.status, response_body: response.body, headers: response.headers)
      end

      def extract_error_message(response)
        body = response.body
        return body["message"].to_s if body.is_a?(Hash) && body["message"]
        return body["error"].to_s if body.is_a?(Hash) && body["error"]

        "T.LY API request failed with status #{response.status}"
      end

      def error_class_for(status)
        case status
        when 400, 422 then ValidationError
        when 401 then AuthenticationError
        when 403 then PermissionError
        when 404 then NotFoundError
        when 429 then RateLimitError
        when 400..499 then ClientError
        else ServerError
        end
      end

      def build_uri(path, query)
        uri = URI.parse("#{base_url}#{path}")
        query_string = build_query_string(query)
        uri.query = query_string unless query_string.nil? || query_string.empty?
        uri
      end

      def build_query_string(query)
        return nil if query.nil?

        pairs = []
        flatten_query_value(query).each do |key, value|
          next if value.nil?

          pairs << "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
        end
        pairs.join("&")
      end

      def flatten_query_value(value, prefix = nil, output = [])
        case value
        when Hash
          value.each do |key, nested_value|
            nested_key = prefix ? "#{prefix}[#{key}]" : key.to_s
            flatten_query_value(nested_value, nested_key, output)
          end
        when Array
          value.each_with_index do |nested_value, index|
            flatten_query_value(nested_value, "#{prefix}[#{index}]", output)
          end
        else
          output << [prefix, value]
        end
        output
      end

      def compact_payload(value)
        case value
        when Hash
          value.each_with_object({}) do |(key, nested_value), obj|
            compacted = compact_payload(nested_value)
            obj[key] = compacted unless compacted.nil?
          end
        when Array
          value.map { |v| compact_payload(v) }.compact
        else
          value
        end
      end

      def path_with_id(path, id)
        path.sub(":id", escape_path_component(id))
      end

      def escape_path_component(component)
        CGI.escape(component.to_s).gsub("+", "%20")
      end
    end
  end
end
