# Rails Lite

A lightweight version of Ruby on Rails -- the "Rails Lite on Rack" web framework.

Rails Lite includes ActiveRecord "Lite", a lightweight version of ActiveRecord from Rails.

The purpose of this Rails Lite project is to demonstrate our understanding of MVC, the Ruby on Rails frameworks, and ActiveRecord-assisted SQL commands.

## Infrastructure

Rails Lite is run on a Rack server, located in `/bin/server.rb`.

### Middlewares

Two custom middlewares are used: Stack Tracer and Static Assets.

#### Stack Tracer Middleware

The first middleware in the middleware stack to rescue all exceptions raised by any subsequent middlewares and app. It outputs a formatted status 500 error when any exception is raised.

#### Static Assets Middleware

Certain static assets are made accessible to the public by sending a GET request with `/public/` included in the path after the hostname.

The Static Asset middleware matches the `/public/` path and responds with the corresponding static asset.

## Architecture and MVC

Rails Lite includes a custom router, controller base, and model base.

### Router

The router creates a route for each controller action. When passed a request, the router runs the corresponding route to call on the corresponding controller action.

### ControllerBase

The ControllerBase functions similarly to the ActionController::Base in Rails. It is the super class that provides the standard controller methods (`render`, `redirect_to`, `session`, and `flash`). User-defined controller actions are invoked by the corresponding route.

### ModelBase

The ModelBase serves as the base class for user-generated models. Included methods are the standard SQL queries:

```
#all
#find
#insert
#update
#save
```

In addition, inheriting from ModelBase grants the `#where` method from the Searchable module to dynamically query from the RDBMS.

The Associatable module is extended as well, to provide the three standard association methods:

```
belongs_to
has_many
has_one_through
```

## Additional Features

### Session & Flash

Both client session and flash notifications are stored as cookies through the Rack cookie-setter and getter methods.

Additionally, Flash has two variations: `flash.now` and `flash`.

`Flash#now` is used for displaying notifications on view renders. Meanwhile, the standard flash is for the flash notification(s) to persist through a redirect via cookie.

### CSRF Protection

To protect against cross-site request forgery (CSRF), the `CSRFProtection#protect_from_forgery` method in the controller sets a CSRF authentication token as a cookie in the response. It also validates for an authenticated request body (as a hidden input) when the request HTTP method is POST.
