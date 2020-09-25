# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

unless Rails.env.production?
  require 'dotenv'
  Dotenv.load(File.join(Rails.root, '.env'))
end

run Rails.application
