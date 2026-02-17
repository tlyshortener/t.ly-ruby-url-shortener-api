# frozen_string_literal: true

require "minitest/autorun"
require "webrick"
require "json"

require "tly_url_shortener_api"

class TestHttpServer
  RequestCapture = Struct.new(
    :request_method,
    :path,
    :query_string,
    :headers,
    :body,
    keyword_init: true
  )

  attr_reader :port, :requests

  def initialize(&handler)
    @handler = handler
    @requests = []
    @server = WEBrick::HTTPServer.new(
      Port: 0,
      Logger: WEBrick::Log.new(File::NULL),
      AccessLog: []
    )

    @server.mount_proc("/") do |req, res|
      @requests << RequestCapture.new(
        request_method: req.request_method,
        path: req.path,
        query_string: req.query_string,
        headers: req.header.transform_values { |v| v.is_a?(Array) ? v.first : v },
        body: req.body
      )
      @handler.call(req, res)
    end
  end

  def start
    @thread = Thread.new { @server.start }
    @port = @server.config[:Port]
    sleep 0.05
  end

  def stop
    @server.shutdown
    @thread.join if @thread
  end
end
