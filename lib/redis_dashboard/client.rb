class RedisDashboard::Client
  attr_reader :url, :connection

  def initialize(url)
    @url = url
  end

  def clients
    connection.client("list")
  end

  def config
    array_reply_to_hash(connection.config("get", "*"))
  end

  def info
    connection.info
  end

  def stats
    stats = connection.info("commandstats").sort { |a, b| b.last["usec"].to_i <=> a.last["usec"].to_i }
    total = stats.reduce(0) { |total, stat| total += stat.last["usec"].to_i }
    stats.each { |stat| stat.last["impact"] = stat.last["usec"].to_f * 100 / total }
    stats
  end

  def slow_commands
    connection.slowlog("get", config["slowlog-max-len"]).map do |entry|
      cmd = RedisDashboard::Command.new
      cmd.id = entry[0]
      cmd.timestamp = entry[1]
      cmd.microseconds = entry[2]
      cmd.command = entry[3]
      cmd
    end.sort{ |left, right| right.microseconds <=> left.microseconds }
  end

  def memory_stats
    array_reply_to_hash(connection.memory("stats"))
  end

  def close
    connection.close if connection
  end

  private

  def connection
    @connection ||= Redis.new(url: url)
  end

  # Array reply is a Redis format which is translated into a hash for convenience.
  def array_reply_to_hash(array)
    hash = {}
    while (pair = array.slice!(0, 2)).any?
      hash[pair.first] = pair.last.is_a?(Array) ? array_reply_to_hash(pair.last) : pair.last
    end
    hash
  end
end
