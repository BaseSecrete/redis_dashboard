require "sinatra/base"
require "redis"

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
    def epoch_to_short_date_time(epoch)
      Time.at(epoch).strftime("%b %d %H:%M")
    end

    def redis_id
      params[:id].to_i
    end
  end
end
