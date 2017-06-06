# Redis Dashboard

It's a Sinatra web app showing monitoring informations about your Redis server.
You can run it in standalone or inside your Rails app.

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

Finally visit http://localhost/redis_dashboar/.

## Authentication

To protect your dashboard you can setup a basic HTTP authentication:

```ruby
RedisDashboard::Application.use(Rack::Auth::Basic) do |user, password|
  user == "USER" && password == "PASSWORD"
end
```
