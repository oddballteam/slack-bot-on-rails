# frozen_string_literal: true

FactoryBot.define do
  factory :slack_thread do
    trait :categories do
      category_list { 'one, two' }
    end

    trait :team do
      team
    end
  end
end
