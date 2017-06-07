# Redis Dashboard

It's a Sinatra web app showing monitoring informations about your Redis server.
You can run it in standalone or inside your Rails app.

[[https://github.com/BaseSecrete/redis_dashboard/screenshot.jpg|alt=redis_dashboard]]

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
match "/redis_dashboard" => RedisDashboard::Application
```

RedisDashboard.urls = ["redis://localhost"]

## Authentication

To protect your dashboard you can setup a basic HTTP authentication:

```ruby
RedisDashboard::Application.use(Rack::Auth::Basic) do |user, password|
  user == "USER" && password == "PASSWORD"
end
```

# MIT License

Made by [Base Secrete][basesecrete.com].
Rails developer? Check out [RoRvsWild][rorvswild.com], our Ruby on Rails application monitoring tool.
