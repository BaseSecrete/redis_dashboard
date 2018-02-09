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

  def close
    connection.close if connection
  end

  private

  def connection
    @connection ||= Redis.new(url: url)
  end
end
