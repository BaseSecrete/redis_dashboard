$LOAD_PATH << File.expand_path(File.dirname(__FILE__)) + "/lib"

require "redis_dashboard"
RedisDashboard::Application.run!
