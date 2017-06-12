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

Add this line in your Gemfile:
```ruby
gem "redis_dashboard"
```

In your terminal run the following command:
```shell
bundle install
```

Then mount the app from `config/routes.rb`:
```ruby
mount RedisDashboard::Application, at: "redis_dashboard"
```

Specify the Redis URLs in `config/redis_dashboard.rb`:
```ruby
RedisDashboard.urls = ["redis://localhost"]
```

Finally visit http://localhost/redis_dashboard/.

## Authentication

To protect your dashboard you can setup a basic HTTP authentication:

```ruby
RedisDashboard::Application.use(Rack::Auth::Basic) do |user, password|
  user == "USER" && password == "PASSWORD"
end
```

## MIT License

Made by [Base Secrète](https://basesecrete.com).

Rails developer? Check out [RoRvsWild](https://rorvswild.com), our Ruby on Rails application monitoring tool.
