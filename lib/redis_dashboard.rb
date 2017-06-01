module RedisDashboard
  def self.urls=(array)
    @urls = array
  end

  def self.urls
    @urls ||= ["redis://localhost"]
  end
end

require "redis_dashboard/client"
require "redis_dashboard/command"
require "redis_dashboard/application"
