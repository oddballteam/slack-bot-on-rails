# This file is used by Rack-based servers to start the application.

require 'dotenv'
require_relative 'config/environment'
Dotenv.load(File.join(Rails.root, '.env')) unless Rails.env.production?

require_relative 'lib/bot/support_bot'

Thread.abort_on_exception = true
Thread.new do
  SupportBot.run
end

run Rails.application
