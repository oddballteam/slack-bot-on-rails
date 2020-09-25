# frozen_string_literal: true

class Team < ApplicationRecord
  scope :active, -> { where(active: true) }

  validates_uniqueness_of :access_token, message: 'has already been used'
  validates_presence_of :access_token
  validates_uniqueness_of :bot_access_token, message: 'has already been used'
  validates_presence_of :bot_access_token
  validates_presence_of :team_id
  validates_uniqueness_of :team_id, message: 'is already registered'

  def self.from_oauth(response)
    access_token = response['access_token']
    bot_access_token = response['bot']['bot_access_token']
    team_id = response['team_id']
    team_name = response['team_name']

    team = Team.find_by(access_token: access_token)
    team ||= Team.find_by(bot_access_token: bot_access_token)
    team ||= Team.find_by(team_id: team_id)

    if team && !team.active?
      team.update(
        active: true, access_token: access_token, bot_access_token: bot_access_token
      )
    else
      team = Team.create(
        access_token: access_token,
        bot_access_token: bot_access_token,
        team_id: team_id,
        name: team_name
      )
    end

    team
  end
end
