# frozen_string_literal: true

# database-less model for interacting with the GitHub API
class GithubIssue
  include ActiveModel::Model
  attr_accessor :id, :body, :html_url, :number, :state
  attr_reader :labels, :title

  # close the github issue on the given repository with the given number
  def close
    client.close_issue(repository, number)
  end

  # set the github issue labels
  def labels=(labels)
    client.update_issue(repository, number, labels: labels) if labels != @labels
    @labels = labels
  end

  # set the github issue title
  def title=(title)
    client.update_issue(repository, number, title: title) if title != @title
    @title = title
  end

  private

  def client
    github.client
  end

  def github
    @github ||= GithubInstallation.last
  end

  def repository
    github.repository
  end
end
