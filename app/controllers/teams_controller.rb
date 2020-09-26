# frozen_string_literal: true

class TeamsController < ApplicationController
  def index
    render json: Team.all
  end

  def new; end

  def create
    unless ENV.key?('SLACK_CLIENT_ID') && ENV.key?('SLACK_CLIENT_SECRET')
      raise 'Missing SLACK_CLIENT_ID or SLACK_CLIENT_SECRET.'
    end

    client = Slack::Web::Client.new
    oauth = client.oauth_access(
      client_id: ENV['SLACK_CLIENT_ID'],
      client_secret: ENV['SLACK_CLIENT_SECRET'],
      code: params.require(:code) # from Slack redirect?
    )

    Rails.logger.info("Oauth response: #{oauth.inspect} #{oauth}")

    team = Team.from_oauth(oauth)

    if team.errors.empty?
      render json: team, status: :created
    else
      render json: team.errors, status: :unprocessable_entity
    end
  end
end
