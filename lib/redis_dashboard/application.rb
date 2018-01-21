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

  get "/stats" do
    erb(:stats, locals: {stats: client.stats})
  end

  get "/slowlog" do
    erb(:slowlog, locals: {commands: client.slow_commands})
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

    def clients_column_description(col)
      # https://redis.io/commands/client-list
      {
        id: "an unique 64-bit client ID (introduced in Redis 2.8.12).",
        addr: "address/port of the client",
        fd: "file descriptor corresponding to the socket",
        age: "total duration of the connection in seconds",
        idle: "idle time of the connection in seconds",
        flags: "client flags (see below)",
        db: "current database ID",
        sub: "number of channel subscriptions",
        psub: "number of pattern matching subscriptions",
        multi: "number of commands in a MULTI/EXEC context",
        qbuf: "query buffer length (0 means no query pending)",
        'qbuf-f': "ree: free space of the query buffer (0 means the buffer is full)",
        obl: "output buffer length",
        oll: "output list length (replies are queued in this list when the buffer is full)",
        omem: "output buffer memory usage",
        events: "file descriptor events (see below)",
        cmd: "last command played",
      }[col.to_sym]
    end

    def client_event_description(event)
      # https://redis.io/commands/client-list
      {
        O: "the client is a slave in MONITOR mode",
        S: "the client is a normal slave server",
        M: "the client is a master",
        x: "the client is in a MULTI/EXEC context",
        b: "the client is waiting in a blocking operation",
        i: "the client is waiting for a VM I/O (deprecated)",
        d: "a watched keys has been modified - EXEC will fail",
        c: "connection to be closed after writing entire reply",
        u: "the client is unblocked",
        U: "the client is connected via a Unix domain socket",
        r: "the client is in readonly mode against a cluster node",
        A: "connection to be closed ASAP",
        N: "no specific flag set",
      }[event.to_sym]
    end
  end
end
