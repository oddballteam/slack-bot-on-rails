# frozen_string_literal: true

FactoryBot.define do
  factory :github_installation do
    github_id { 1 }
    repository { 'octo/cat' }
    metadata { '' }

    trait :access_token do
      access_token { 'ABC' }
      token_expires_at { Time.zone.tomorrow }
    end
  end
end
