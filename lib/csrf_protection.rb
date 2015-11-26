require 'securerandom'
require 'json'
require 'byebug'

module CSRFProtection
  def protect_from_forgery
    authenticate_csrf_token

    @authenticity_token = generate_authenticity_token
    set_csrf_cookie
  end

  def authenticity_token
    @authenticity_token
  end

  private

  def set_csrf_cookie
    attributes = { path: "/", value: @authenticity_token }

    @res.set_cookie("_rails_lite_app_csrf", attributes)
  end

  def generate_authenticity_token
    SecureRandom.base64(64)
  end

  def authenticate_csrf_token
    return if @req.get?

    cookie_token = @req.cookies["_rails_lite_app_csrf"]
    form_token = @params["authenticity_token"]

    raise "InvalidAuthenticityToken" unless cookie_token == form_token
  end
end
