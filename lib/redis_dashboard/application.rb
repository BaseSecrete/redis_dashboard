require "sinatra/base"
require "redis"
require "uri"

class RedisDashboard::Application < Sinatra::Base
  after { close_clients }

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

  get "/biggest_keys" do
    erb(:biggest_keys, locals: {biggest_keys: client.biggest_keys})
  end

  get "/application.css" do
    scss(:application, style: :expanded)
  end

  def client
    @client ||= RedisDashboard::Client.new(RedisDashboard.urls[redis_id.to_i])
  end

  def clients
    @clients ||= RedisDashboard.urls.map do |url|
      RedisDashboard::Client.new(url)
    end
  end

  def close_clients
    @client.close if @client
    @clients.each { |client| client.close } if @clients
  end

  helpers do
    def page_title
      "#{URI(client.url).host} (#{client.info["role"]})"
    end

    def epoch_to_short_date_time(epoch)
      Time.at(epoch).strftime("%b %d %H:%M")
    end

    def redis_id
      params[:id]
    end

    def active_page?(path='')
      request.path_info == '/' + path
    end
  end
end
