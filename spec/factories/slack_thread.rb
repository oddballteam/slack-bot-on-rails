# frozen_string_literal: true

FactoryBot.define do
  factory :slack_thread do
    trait :team do
      team
    end
  end
end
