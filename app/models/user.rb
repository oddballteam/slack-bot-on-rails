# frozen_string_literal: true

# model for a Slack User
class User < ApplicationRecord
  belongs_to :team
  validates_presence_of :slack_id
  validates_uniqueness_of :slack_id, message: 'is already registered'

  # slack web client
  def slack_client
    team&.slack_client
  end

  # get the slack user names and image url
  def update_profile_details
    profile = slack_client.users_profile_get(user: slack_id)
    self.display_name = profile['profile']['display_name']
    self.image_url = profile['profile']['image_72']
    self.real_name = profile['profile']['real_name']
    save
  rescue Slack::Web::Api::Errors::MissingScope => _e
    false
  end
end
