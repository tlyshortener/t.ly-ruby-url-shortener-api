# frozen_string_literal: true

require_relative "lib/tly/url_shortener_api/version"

Gem::Specification.new do |spec|
  spec.name = "tly-url-shortener-api"
  spec.version = Tly::UrlShortenerApi::VERSION
  spec.authors = ["T.LY"]
  spec.email = ["support@t.ly"]

  spec.summary = "Official Ruby client for the T.LY URL Shortener API"
  spec.description = "Ruby client for creating, managing, and analyzing short links with the T.LY API."
  spec.homepage = "https://t.ly"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "https://github.com/tly/url-shortener-ruby",
    "changelog_uri" => "https://github.com/tly/url-shortener-ruby/blob/main/CHANGELOG.md"
  }

  spec.files = Dir.chdir(__dir__) do
    Dir[
      "lib/**/*.rb",
      "test/**/*.rb",
      "README.md",
      "CHANGELOG.md",
      "LICENSE.txt",
      "Rakefile"
    ]
  end

  spec.bindir = "exe"
  spec.executables = []
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
