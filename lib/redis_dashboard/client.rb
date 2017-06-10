class RedisDashboard::Client
  attr_reader :url, :connection

  def initialize(url)
    @url = url
  end

  def clients
    connection.client.call([:client, "list"]).split("\n").map do |line|
      line.split(" ").reduce({}) do |hash, str|
        pair = str.split("=")
        hash[pair[0]] = pair[1]
        hash
      end
    end
  end

  def config
    hash = {}
    array = connection.config("get", "*")
    while (pair = array.slice!(0, 2)).any?
      hash[pair.first] = pair.last
    end
    hash
  end

  def info
    connection.info
  end

  def close
    connection.close if connection
  end

  def slow_commands(length = 128) # 128 is the default slowlog-max-len
    connection.slowlog("get", length).map do |entry|
      cmd = RedisDashboard::Command.new
      cmd.id = entry[0]
      cmd.timestamp = entry[1]
      cmd.microseconds = entry[2]
      cmd.command = entry[3]
      cmd
    end.sort{ |left, right| right.microseconds <=> left.microseconds }
  end

  def key(key) 
    key_type = connection.type(key)
    values = case key_type
             when "string"
               [connection.get(key)]
             when "hash"
               connection.hgetall(key)
             when "set"
               connection.smembers(key)
             when "zset"
               connection.zrange(key, 0, -1, with_scores: true)
             end
    {key: key, values: values, type: key_type}
  end

  def keys(params = {})
    cursor = params.fetch(:cursor, 0)
    next_cursor, keys = connection.scan(cursor)
    keys = keys.map do |key| 
      key_type = connection.type(key)
      value = case key_type
              when "string"
                connection.get(key)
              when "hash"
                connection.hlen(key)
              when "set"
                "#{connection.scard(key)}"
              when "zset"
                "#{connection.zcount(key, "-inf", "+inf")}"
              end
      {key: key, value: value, type: key_type}
    end
    {next_cursor: next_cursor, keys: keys}
  end

  private

  def connection
    @connection ||= Redis.new(url: url)
  end
end
