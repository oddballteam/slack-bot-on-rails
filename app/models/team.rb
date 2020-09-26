# frozen_string_literal: true

# model for a Slack Team
class Team < ApplicationRecord
  scope :active, -> { where(active: true) }

  validates_uniqueness_of :access_token, message: 'has already been used'
  validates_presence_of :access_token
  validates_presence_of :team_id
  validates_uniqueness_of :team_id, message: 'is already registered'

  # creates or updates a Slack Team that has OAuth'd this application
  def self.create_or_update_from_oauth(response)
    access_token = response['access_token']
    team_id = response.dig('team', 'id')
    user_access_token = response.dig('authed_user', 'access_token')

    team = Team.find_by(access_token: access_token)
    team ||= Team.find_by(user_access_token: user_access_token)
    team ||= Team.find_by(team_id: team_id)

    if team && !team.active?
      team.update(active: true, access_token: access_token, user_access_token: user_access_token)
    else
      team = Team.create(
        access_token: access_token,
        bot_user_id: response['bot_user_id'],
        team_id: team_id,
        name: response.dig('team', 'name'),
        user_id: response.dig('authed_user', 'id'),
        user_access_token: user_access_token
      )
    end

    team
  end
end
