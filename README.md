# Redis Dashboard

A Sinatra web app showing monitoring informations about your Redis servers.
You can run it in standalone or inside your Rails app.

![Redis dashboard](https://github.com/BaseSecrete/redis_dashboard/blob/master/screenshot.jpg)

## Features

#### List of your redis servers
  - Connections
  - Memory
  - Commands per second

#### Detailed views for each server
  - Redis INFO output
  - Redis CONFIG GET output
  - Redis CLIENT LIST output
  - Redis SLOWLOG GET output

## Installation inside a Rails app

Add to your Gemfile `gem "redis_dashboard"` and run `bundle install`.

Then mount the app from `config/routes.rb`:
```ruby
mount RedisDashboard::Application, at: "redis"
```

By default Redis dashboard tries to connect to `REDIS_URL` environment variable or to `localhost`. You can specify any other URL by adding an initializer in `config/initializers/redis_dashboard.rb` :
```ruby
RedisDashboard.urls = [ENV["REDIS_URL"] || "redis://localhost"]
```

Finally visit http://localhost:3000/redis.

## Authentication and permissions

To protect your dashboard you can setup a basic HTTP authentication :

```ruby
# config/initializers/redis_dashboard.rb
RedisDashboard::Application.use(Rack::Auth::Basic) do |user, password|
  user == "USER" && password == "PASSWORD"
end
```

In case you handle authentication with Devise, you can perform the permission verification directly from the routes :

```ruby
# config/routes.rb
authenticate :user, -> (u) { u.admin? } do # Supposing there is a User#admin? method
  mount RedisDashboard::Application, at: "redis"
end
```

## MIT License

Made by [Base Secrète](https://basesecrete.com).

Rails developer? Check out [RoRvsWild](https://rorvswild.com), our Ruby on Rails application monitoring tool.
