# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    access_token { "xoxb-#{Faker::Number.unique.number(digits: 7)}" }
    bot_user_id { "U#{Faker::Alphanumeric.unique.alphanumeric(number: 8).upcase}" }
    name { 'Slack Soccer Team' }
    slack_id { "T#{Faker::Alphanumeric.unique.alphanumeric(number: 8).upcase}" }
    user_access_token { 'xoxp-5678' }
    user_id { 'U5678' }

    trait :inactive do
      active { false }
    end
  end
end
