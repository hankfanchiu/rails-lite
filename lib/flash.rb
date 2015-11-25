require 'json'

class Flash
  def initialize(req)
    request_flash_cookie = req.cookies['_rails_lite_app_flash']

    if request_flash_cookie
      @flash_now = JSON.parse(request_flash_cookie)
    else
      @flash_now = {}
    end

    @flash_cookie = {}
  end

  def [](key)
    @flash_now[key.to_s] || @flash_now[key]
  end

  def []=(key, val)
    @flash_cookie[key] = val
  end

  def now
    @flash_now
  end

  def store_flash(res)
    attributes = { path: '/', value: @flash_cookie.to_json }
    res.set_cookie('_rails_lite_app_flash', attributes)
  end
end
