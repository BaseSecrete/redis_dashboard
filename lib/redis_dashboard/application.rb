require "sinatra/base"
require "erubi"
require "redis"
require "uri"

class RedisDashboard::Application < Sinatra::Base
  set :erb, escape_html: true

  after { close_clients }

  get "/" do
    erb(:index, locals: {clients: clients})
  end

  get "/:server/config" do
    erb(:config, locals: {config: client.config})
  end

  get "/:server/clients" do
    erb(:clients, locals: {clients: client.clients})
  end

  get "/:server/stats" do
    erb(:stats, locals: {stats: client.stats})
  end

  get "/:server/slowlog" do
    erb(:slowlog, locals: {client: client, commands: client.slow_commands})
  end

  get "/:server/memory" do
    stats = mute_redis_command_error { client.memory_stats } || {}
    erb(:memory, locals: {client: client, stats: stats })
  end

  get "/:server/keyspace" do
    erb(:keyspace, locals: {keyspace: client.keyspace})
  end

  get "/:server/keyspace/:db" do
    client.connection.select(params[:db].sub(/^db/, ""))
    erb(:keys, locals: {client: client, keys: client.keys(params[:query])})
  end

  get "/:server/keyspace/:db/*" do
    params[:key] = params[:splat].first
    client.connection.select(params[:db].sub(/^db/, ""))
    erb(:key, locals: {client: client})
  end

  get "/:server" do
    erb(:info, locals: {info: client.info})
  end

  def client
    return @client if @client
    if url = RedisDashboard.urls.find { |url| URI(url).host == params[:server] }
      @client ||= RedisDashboard::Client.new(url)
    else
      raise Sinatra::NotFound
    end
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

    def active_page_css(path)
      request.path_info == path && "active"
    end

    def active_path_css(path)
      request.path_info.start_with?(path) && "active"
    end

    def format_impact_percentage(percentage)
      percentage < 1 ? "< 1 <small>%</small>" : "#{percentage.round} <small>%</small>"
    end

    def format_usec(usec)
      "#{usec}&nbsp;<small>㎲</small>"
    end

    def compute_cache_hit_ratio(info)
      hits = info["keyspace_hits"].to_i
      misses = info["keyspace_misses"].to_i
      if (total = hits + misses) > 0
        hits * 100.0 / total
      else
        0
      end
    end

    def render_key_data(key)
      type = client.connection.type(params[:key])
      erb(:"key/#{type}", locals: {key: key})
    rescue Errno::ENOENT
      erb(:"key/unsupported", locals: {key: key})
    end

    def mute_redis_command_error(&block)
      block.call
    rescue Redis::CommandError
    end

    def clients_column_description(col)
      # https://redis.io/commands/client-list
      @clients_column_description ||= {
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
      }
      @clients_column_description[col.to_sym]
    end

    def client_event_description(event)
      # https://redis.io/commands/client-list
      @client_event_description ||= {
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
      }
      @client_event_description[event.to_sym]
    end
  end
end
