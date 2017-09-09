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

  def biggest_keys
    connection.eval(<<-LUA)
      local function compareSizes(left, right)
        return left[2] > right[2]
      end

      local function biggest_keys(limit)
        local cursor = "0"
        local entries = {}
        local min_size = 0
        repeat
          local ret = redis.call("scan", cursor)
          for _, key in ipairs(ret[2]) do
            local size = string.len(redis.call("DUMP", key))
            if size > min_size then
              table.insert(entries, {key, size})
              table.sort(entries, compareSizes)
              if #entries > limit then
                table.remove(entries)
              end
            end
          end
          cursor = ret[1]
        until cursor == "0"
        return entries
      end

      return biggest_keys(100)
    LUA
  end

  private

  def connection
    @connection ||= Redis.new(url: url)
  end
end
