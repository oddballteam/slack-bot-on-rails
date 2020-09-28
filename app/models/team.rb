# frozen_string_literal: true

# model for a Slack Team
class Team < ApplicationRecord
  scope :active, -> { where(active: true) }

  validates_uniqueness_of :access_token, message: 'has already been used'
  validates_presence_of :access_token
  validates_presence_of :slack_id
  validates_uniqueness_of :slack_id, message: 'is already registered'

  # creates or updates a Slack Team that has OAuth'd this application
  def self.create_or_update_from_oauth(response)
    access_token = response['access_token']
    slack_id = response.dig('team', 'id')
    user_access_token = response.dig('authed_user', 'access_token')

    team = Team.find_by(access_token: access_token)
    team ||= Team.find_by(user_access_token: user_access_token)
    team ||= Team.find_by(slack_id: slack_id)

    if team && !team.active?
      team.update(active: true, access_token: access_token, user_access_token: user_access_token)
    else
      team = Team.create(
        access_token: access_token,
        bot_user_id: response['bot_user_id'],
        slack_id: slack_id,
        name: response.dig('team', 'name'),
        slack_user_id: response.dig('authed_user', 'id'),
        user_access_token: user_access_token
      )
    end

    team
  end

  # slack web client w/ token auth pre-populated
  def slack_client
    @slack_client ||= Slack::Web::Client.new(token: access_token) unless access_token&.blank?
  end
end
