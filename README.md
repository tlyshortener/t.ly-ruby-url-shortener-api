# T.LY Ruby URL Shortener API

Ruby client library for the [T.LY API](https://t.ly).

## Installation

Add this line to your application's Gemfile:

```ruby
gem "tly-url-shortener-api"
```

Then run:

```bash
bundle install
```

Or install directly:

```bash
gem install tly-url-shortener-api
```

## Quick Start

```ruby
require "tly_url_shortener_api"

client = Tly::UrlShortenerApi::Client.new(api_token: ENV.fetch("TLY_API_TOKEN"))

response = client.shorten_link(
  long_url: "https://example.com/very/long/path",
  domain: "https://t.ly",
  description: "My short link"
)

puts response.status
puts response.body
```

## Authentication

This gem sends your API token as a bearer token header:

```http
Authorization: Bearer <YOUR_TOKEN>
```

## Available API Methods

### OneLink Stats

- `onelink_stats(short_url:, start_date: nil, end_date: nil)`
- `delete_onelink_stats(short_url:)`

### ShortLink Management

- `shorten_link(long_url:, domain: nil, expire_at_datetime: nil, description: nil, public_stats: nil, meta: nil)`
- `get_link(short_url:)`
- `update_link(short_url:, long_url: nil, expire_at_datetime: nil, description: nil, public_stats: nil, meta: nil)`
- `delete_link(short_url:)`
- `expand_link(short_url:, password: nil)`
- `list_links(search: nil, tag_ids: nil, pixel_ids: nil, start_date: nil, end_date: nil, domains: nil)`
- `bulk_shorten_links(links:, domain: nil, tags: nil, pixels: nil)`
- `bulk_update_links(links:, tags: nil, pixels: nil)`

### ShortLink Stats

- `link_stats(short_url:, start_date: nil, end_date: nil)`

### UTM Presets

- `create_utm_preset(name:, source:, medium:, campaign:, content: nil, term: nil)`
- `list_utm_presets`
- `get_utm_preset(id:)`
- `update_utm_preset(id:, name: nil, source: nil, medium: nil, campaign: nil, content: nil, term: nil)`
- `delete_utm_preset(id:)`

### OneLinks

- `list_onelinks(page: nil)`

### Pixels

- `create_pixel(name:, pixel_id:, pixel_type:)`
- `list_pixels`
- `get_pixel(id:)`
- `update_pixel(id:, name: nil, pixel_id: nil, pixel_type: nil)`
- `delete_pixel(id:)`

### QR Codes

- `get_qr_code(short_url:, output: nil, format: nil)`
- `update_qr_code(short_url:, image: nil, background_color: nil, corner_dots_color: nil, dots_color: nil, dots_style: nil, corner_style: nil)`

### Tags

- `list_tags`
- `create_tag(tag:)`
- `get_tag(id:)`
- `update_tag(id:, tag:)`
- `delete_tag(id:)`

## Response Object

Every method returns `Tly::UrlShortenerApi::Response` with:

- `status` - HTTP status code
- `headers` - response headers hash (lowercase keys)
- `body` - parsed JSON (Hash/Array) or raw body string
- `raw_body` - unparsed body string
- `success?` - true for HTTP 2xx

## Error Handling

Failed responses raise typed errors:

- `Tly::UrlShortenerApi::AuthenticationError`
- `Tly::UrlShortenerApi::PermissionError`
- `Tly::UrlShortenerApi::NotFoundError`
- `Tly::UrlShortenerApi::ValidationError`
- `Tly::UrlShortenerApi::RateLimitError`
- `Tly::UrlShortenerApi::ServerError`
- `Tly::UrlShortenerApi::TransportError` (network/timeout/connection failures)

```ruby
begin
  client.get_link(short_url: "https://t.ly/missing")
rescue Tly::UrlShortenerApi::NotFoundError => e
  puts e.status
  puts e.response_body
end
```

## Configure Base URL and Timeouts

```ruby
client = Tly::UrlShortenerApi::Client.new(
  api_token: ENV.fetch("TLY_API_TOKEN"),
  base_url: "https://api.t.ly",
  open_timeout: 5,
  read_timeout: 20
)
```

## Development

```bash
bundle install
bundle exec rake test
```

## Release to RubyGems

1. Update version in `lib/tly/url_shortener_api/version.rb`.
2. Update `CHANGELOG.md`.
3. Build the gem:

```bash
gem build tly-url-shortener-api.gemspec
```

4. Push to RubyGems:

```bash
gem push tly-url-shortener-api-<version>.gem
```

## License

MIT. See `LICENSE.txt`.
