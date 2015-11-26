require 'rack'
require_relative '../lib/controller_base'
require_relative '../lib/stack_tracer'
require_relative '../lib/asset_server'

class NotFoundController < ControllerBase
  def go
    if @req.path == "/cats"
      render_content("hello cats!", "text/html")
    else
      raise "Not Found"
    end
  end
end

my_app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  NotFoundController.new(req, res).go
  res.finish
end

app = Rack::Builder.new do
  use StackTracer
  use AssetServer
  run my_app
end

Rack::Server.start(
  app: app,
  Port: 3000
)
