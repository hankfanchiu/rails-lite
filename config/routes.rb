require_relative '../lib/controller_base'
require_relative '../app/controllers/cats_controller'

class Routes
  def run(router)
    router.draw do
      get Regexp.new("^/cats$"), CatsController, :index
      get Regexp.new("^/cats/new$"), CatsController, :new
      get Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :show
      post Regexp.new("^/cats$"), CatsController, :create
    end
  end
end
