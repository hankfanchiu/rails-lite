# Rails Lite

An App Academy solo project to build our own version of Rails -- the "Rails Lite on Rack" web framework.

## Architecture & Features

Currently, ActiveRecord Lite has not been completed and integrated with Rails Lite.

### Stack Tracer Middleware

The first middleware in the middleware stack to rescue all exceptions raised by any subsequent middlewares and app. It outputs a formatted status 500 error when any exception is raised.

### Static Asset Middleware

Certain static assets are made accessible to the public by sending a GET request with `/public/` included in the path after the hostname.

The Static Asset middleware matches the `/public/` path and responds with the corresponding static asset.

### Router

The router creates a route for each controller action. When passed a request, the router runs the corresponding route to call on the corresponding controller action.

### ControllerBase

The ControllerBase functions similarly to the ActionController::Base in Rails. It is the super class that provides the standard controller methods (`render`, `redirect_to`, `session`, and `flash`). User-defined controller actions are invoked by the corresponding route.

### CSRF Protection

To protect against cross-site request forgery (CSRF), the `CSRFProtection#protect_from_forgery` method in the controller sets a CSRF authentication token as a cookie in the response. It also validates for an authenticated request body (as a hidden input) when the request HTTP method is POST.
