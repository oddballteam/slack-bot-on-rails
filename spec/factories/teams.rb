# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    access_token { 'ACC111' }
    bot_access_token { 'BOT999' }
    team_id { 'HIGHLAND' }

    trait :inactive do
      active { false }
    end
  end
end
