require 'rack'

class StaticAssets
  attr_reader :app

  def initialize(app)
    @app = app
    @public_path = Regexp.new("^\/assets\/")
  end

  def call(env)
    req = Rack::Request.new(env)
    path = req.path

    if path.match(@public_path)
      render_asset(path)
    else
      app.call(env)
    end
  end

  private

  def render_asset(path)
    asset_path = path.sub(@public_path, "/public/")
    file = File.read(asset_path)

    res = Rack::Response.new
    res['Content-Type'] = 'mime-type'
    res.write(file)
    res.finish
  end
end
