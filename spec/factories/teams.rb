# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    access_token { 'xoxb-4567890' }
    bot_user_id { 'U0KRQLJ4H' }
    name { 'Slack Soccer Team' }
    team_id { 'T9TK3CAKE' }
    user_access_token { 'xoxp-5678' }
    user_id { 'U5678' }

    trait :inactive do
      active { false }
    end
  end
end
