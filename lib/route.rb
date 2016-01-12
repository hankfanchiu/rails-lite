class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    req_method = req.request_method.downcase.to_sym

    (req.path =~ @pattern) && (req_method == @http_method)
  end

  def run(req, res)
    route_params = {}
    params_from_pattern = @pattern.match(req.path)

    params_from_pattern.names.each do |key|
      route_params[key] = params_from_pattern[key]
    end

    controller = @controller_class.new(req, res, route_params)
    controller.invoke_action(@action_name)
  end
end
