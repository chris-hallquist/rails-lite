class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    req.request_method.downcase.to_sym == @http_method &&
      req.path.match(pattern)
  end

  def run(req, res)
    match_data = pattern.match(req.path)
    route_params = {}
    pattern.named_captures.each do |key, value|
      route_params[key] = match_data[route_params[value[0]]]
    end
    controller_class.new(req, res, route_params).invoke_action(action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method.to_s) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    @routes.each do |route|
      return route if route.matches?(req)
    end
    nil
  end

  def run(req, res)
    if match(req)
      match(req).run(req, res)
    else
      res.status = 404
    end
  end
end
