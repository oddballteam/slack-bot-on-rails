# frozen_string_literal: true

require 'openssl'
require 'jwt'

# keep track of github installation ids and metadata
class GithubInstallation < ApplicationRecord
  validates :github_id, presence: true, uniqueness: true

  # get/update the github installation access token
  def access_token
    if token_expires_at.nil? || token_expires_at < Time.zone.now
      jwt_client = Octokit::Client.new(bearer_token: new_jwt_token)
      response = jwt_client.create_app_installation_access_token(
        github_id,
        accept: Octokit::Preview::PREVIEW_TYPES[:integrations]
      )
      update(access_token: response.token, token_expires_at: response.expires_at)
    end

    super
  end

  # close the github issue on the given repository with the given number
  def close_issue(issue_number:)
    client.close_issue(repository, issue_number)
  end

  # create a github issue on the given repository with the given summary/title
  def create_issue(title:, body: nil, labels: [])
    client.create_issue(repository, title, body, labels: labels)
  end

  # set the github issue labels
  def label_issue(issue_number:, labels:)
    client.update_issue(repository, issue_number, labels: labels)
  end

  # update the github issue description with links
  def link_issue(slack_thread)
    description = ApplicationController.render(
      template: 'issues/description.md',
      layout: nil,
      locals: {slack_thread: slack_thread}
    )
    client.update_issue(repository, slack_thread.issue_number, body: description)
  end

  private

  def client
    @client ||= Octokit::Client.new(access_token: access_token)
  end

  def new_jwt_token
    credentials = Rails.application.credentials.github
    private_pem = credentials[:app_pem]
    private_key = OpenSSL::PKey::RSA.new(private_pem)

    payload = {
      # issued at time
      iat: Time.zone.now.to_i,
      # JWT expiration time (10 minute maximum)
      exp: Time.zone.now.to_i + (10 * 60),
      # GitHub App's identifier
      iss: credentials[:app_id]
    }

    JWT.encode(payload, private_key, 'RS256')
  end
end
