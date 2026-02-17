# frozen_string_literal: true

require_relative "test_helper"

class ClientTest < Minitest::Test
  def test_shorten_link_sends_bearer_and_json
    with_server do |server|
      client = build_client(server)

      response = client.shorten_link(
        long_url: "https://example.com/long/path",
        description: "Example link"
      )

      request = server.requests.last
      body = JSON.parse(request.body)

      assert_equal 200, response.status
      assert_equal true, response.body["ok"]
      assert_equal "Bearer test_token", request.headers["authorization"]
      assert_equal "application/json", request.headers["accept"]
      assert_equal "https://example.com/long/path", body["long_url"]
      assert_equal "Example link", body["description"]
      refute body.key?("domain")
    end
  end

  def test_list_links_serializes_indexed_array_query
    with_server do |server|
      client = build_client(server)

      client.list_links(
        tag_ids: [1, 2],
        pixel_ids: [10],
        domains: ["t.ly", "my.t.ly"]
      )

      query_string = server.requests.last.query_string

      assert_includes query_string, "tag_ids%5B0%5D=1"
      assert_includes query_string, "tag_ids%5B1%5D=2"
      assert_includes query_string, "pixel_ids%5B0%5D=10"
      assert_includes query_string, "domains%5B0%5D=t.ly"
      assert_includes query_string, "domains%5B1%5D=my.t.ly"
    end
  end

  def test_non_json_response_body_is_returned_raw
    with_server(content_type: "image/png", body: "PNG_BINARY".b) do |server|
      client = build_client(server)

      response = client.get_qr_code(short_url: "https://t.ly/abc")

      assert_equal "PNG_BINARY".b, response.body
      assert_equal "PNG_BINARY".b, response.raw_body
      assert_equal true, response.success?
    end
  end

  def test_raises_typed_error_for_unauthorized
    with_server(status: 401, body: JSON.generate({ message: "Unauthorized" })) do |server|
      client = build_client(server)

      error = assert_raises(Tly::UrlShortenerApi::AuthenticationError) do
        client.get_link(short_url: "https://t.ly/missing")
      end

      assert_equal 401, error.status
      assert_equal "Unauthorized", error.message
    end
  end

  def test_parses_vendor_json_content_types
    with_server(content_type: "application/problem+json", body: JSON.generate({ error: "problem" })) do |server|
      client = build_client(server)
      response = client.get_link(short_url: "https://t.ly/abc")

      assert_equal({ "error" => "problem" }, response.body)
    end
  end

  def test_raises_transport_error_for_network_failures
    client = Tly::UrlShortenerApi::Client.new(
      api_token: "test_token",
      base_url: "https://api.t.ly"
    )

    Net::HTTP.stub(:start, proc { raise Errno::ECONNREFUSED, "Connection refused" }) do
      error = assert_raises(Tly::UrlShortenerApi::TransportError) do
        client.get_link(short_url: "https://t.ly/abc")
      end

      assert_includes error.message, "transport error"
    end
  end

  def test_rejects_invalid_base_url
    error = assert_raises(ArgumentError) do
      Tly::UrlShortenerApi::Client.new(api_token: "token", base_url: "not-a-url")
    end

    assert_includes error.message, "absolute HTTP(S) URL"
  end

  private

  def build_client(server)
    Tly::UrlShortenerApi::Client.new(
      api_token: "test_token",
      base_url: "http://127.0.0.1:#{server.port}"
    )
  end

  def with_server(status: 200, content_type: "application/json", body: JSON.generate({ ok: true }), &block)
    server = TestHttpServer.new do |_req, res|
      res.status = status
      res["Content-Type"] = content_type
      res.body = body
    end

    server.start
    yield(server)
  ensure
    server&.stop
  end
end
