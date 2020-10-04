# frozen_string_literal: true

# Create Slack Teams as they install the application
class TeamsController < ApplicationController
  def index
    render json: Team.all
  end

  def new
    @client_id = Rails.application.credentials.slack[:client_id]
    @scopes = Team::SCOPES
  end

  # Create Slack Teams as they install the application
  def create
    credentials = Rails.application.credentials.slack
    unless credentials[:client_id] && credentials[:client_secret]
      raise 'Missing :client_id or :client_secret from Rails.application.credentials.slack.'
    end

    client = Slack::Web::Client.new
    oauth_params = {
      client_id: credentials[:client_id],
      client_secret: credentials[:client_secret],
      code: params.require(:code) # from Slack redirect
    }
    Rails.logger.info("Oauth params: #{oauth_params.inspect} #{oauth_params}")

    oauth = client.oauth_v2_access(oauth_params)

    Rails.logger.info("Oauth response: #{oauth.inspect} #{oauth}")

    team = Team.create_or_update_from_oauth(oauth)

    if team.errors.empty?
      render json: team, status: :created
    else
      render json: team.errors, status: :unprocessable_entity
    end
  end
end
