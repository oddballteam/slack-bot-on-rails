# frozen_string_literal: true

# model for a Slack User
class User < ApplicationRecord
  belongs_to :team
  has_many :slack_threads, dependent: :destroy, inverse_of: :user
  validates :slack_id, presence: true
  validates :slack_id, uniqueness: {message: 'is already registered'}

  # slack web client
  def slack_client
    team&.slack_client
  end

  # get the slack user names and image url
  def update_profile_details
    # https://api.slack.com/methods/users.profile.get
    # scopes: users.profile:read
    profile = slack_client.users_profile_get(user: slack_id)
    self.display_name = profile['profile']['display_name']
    self.image_url = profile['profile']['image_72']
    self.real_name = profile['profile']['real_name']
    save
  rescue Slack::Web::Api::Errors::MissingScope => _e
    false
  end
end
