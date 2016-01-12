require 'rack'
require_relative '../lib/stack_tracer'
require_relative '../lib/static_assets'
require_relative '../lib/router'

router = Router.new
Routes.new.run(router)

cat_app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

app = Rack::Builder.new do
  use StackTracer
  use StaticAssets
  run cat_app
end

Rack::Server.start(
 app: app,
 Port: 3000
)
