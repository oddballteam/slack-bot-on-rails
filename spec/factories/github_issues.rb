# frozen_string_literal: true

FactoryBot.define do
  factory :github_issue do
    id { 1 }
    html_url { 'https://github.com/octocat/Hello-World/issues/1347' }
    number { 1347 }
    state { 'open' }

    trait :closed do
      state { 'closed' }
    end
  end
end
