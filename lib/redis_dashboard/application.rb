require "sinatra/base"
require "redis"
require "uri"

class RedisDashboard::Application < Sinatra::Base
  after { client.close }

  get "/" do
    erb(:index, locals: {clients: clients})
  end

  get "/info" do
    erb(:info, locals: {info: client.info})
  end

  get "/config" do
    erb(:config, locals: {config: client.config})
  end

  get "/keys/:key" do
    erb(:key, locals: client.key(params["key"]))
  end

  get "/keys" do
    erb(:keys, locals: client.keys(params))
  end

  get "/clients" do
    erb(:clients, locals: {clients: client.clients})
  end

  get "/slowlog" do
    erb(:slowlog, locals: {commands: client.slow_commands})
  end

  get "/application.css" do
    scss(:application, style: :expanded)
  end

  def client
    @client ||= RedisDashboard::Client.new(RedisDashboard.urls[redis_id])
  end

  def clients
    RedisDashboard.urls.map { |url| RedisDashboard::Client.new(url) }
  end

  helpers do
    def page_title
      "#{URI(client.url).host} (#{client.info["role"]})"
    end

    def epoch_to_short_date_time(epoch)
      Time.at(epoch).strftime("%b %d %H:%M")
    end

    def redis_id
      params[:id].to_i
    end

    def active_page?(path='')
      request.path_info == '/' + path
    end
  end
end
