$LOAD_PATH << File.expand_path(File.dirname(__dir__)) + '/lib'

require 'redis_dashboard'
RedisDashboard::Application.run!
