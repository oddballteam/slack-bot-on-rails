# legacy API token config:
Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end