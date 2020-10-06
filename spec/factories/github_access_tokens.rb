# frozen_string_literal: true

FactoryBot.define do
  factory :github_access_token, class: OpenStruct do
    token { 'v1.1f699f1069f60xxx' }
    expires_at { Time.zone.tomorrow.iso8601 }
    permissions do
      {
        'issues' => 'write',
        'contents' => 'read'
      }
    end
  end
end
