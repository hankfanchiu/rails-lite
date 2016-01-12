require 'json'

class Session
  def initialize(req)
    request_cookie = req.cookies['_rails_lite_app_session']

    if request_cookie
      @cookie = JSON.parse(request_cookie)
    else
      @cookie = {}
    end
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  def store_session(res)
    attributes = { path: '/', value: @cookie.to_json }
    res.set_cookie('_rails_lite_app_session', attributes)
  end
end
