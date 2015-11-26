require 'rack'

class AssetServer
  attr_reader :app

  def initialize(app)
    @app = app
    @public_path = Regexp.new("^\/public\/")
  end

  def call(env)
    req = Rack::Request.new(env)
    path = req.path

    if match_public?(path)
      render_asset(path)
    else
      app.call(env)
    end
  end

  private

  def match_public?(path)
    path.match(@public_path)
  end

  def render_asset(path)
    asset_path = path.sub(@public_path, "")
    file = File.read(asset_path)

    res = Rack::Response.new
    res['Content-Type'] = 'mime-type'
    res.write(file)
    res.finish
  end
end
