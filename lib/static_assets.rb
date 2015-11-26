require 'erb'
require 'rack'

class StaticAssets
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      app.call(env)
    rescue => exception
      render_exception(exception)
    end
  end

  private

  def render_exception(exception)
    body = response_body(exception)

    res = Rack::Response.new
    res.status = 500
    res['Content-Type'] = 'text/html'
    res.write(body)
    res.finish
  end

  def response_body(exception)
    file_content = File.read('views/errors/runtime.html.erb')
    error_template = ERB.new(file_content)

    error_template.result(binding)
  end
end
