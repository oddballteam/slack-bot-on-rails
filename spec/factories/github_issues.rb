# frozen_string_literal: true

FactoryBot.define do
  factory :github_issue, class: OpenStruct do
    id { 1 }
    node_id { 'MDU6SXNzdWUx' }
    url { 'https://api.github.com/repos/octocat/Hello-World/issues/1347' }
    repository_url { 'https://api.github.com/repos/octocat/Hello-World' }
    labels_url { 'https://api.github.com/repos/octocat/Hello-World/issues/1347/labels{/name}' }
    comments_url { 'https://api.github.com/repos/octocat/Hello-World/issues/1347/comments' }
    events_url { 'https://api.github.com/repos/octocat/Hello-World/issues/1347/events' }
    html_url { 'https://github.com/octocat/Hello-World/issues/1347' }
    number { 1347 }
    state { 'open' }
    title { 'Found a bug' }
    body { "I'm having a problem with this." }

    trait :closed do
      state { 'closed' }
    end
  end
end
