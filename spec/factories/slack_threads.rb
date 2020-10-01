# frozen_string_literal: true

FactoryBot.define do
  factory :slack_thread do
    channel { 'ABC123' }
    latest_reply_ts { '1601259545.009300' }
    reply_count { Faker::Number.within(range: 1..10) }
    slack_ts { '1601259545.006300' }
    started_at { Faker::Date.in_date_period(month: 1) }

    trait :categories do
      category_list { 'one, two' }
    end

    trait :links do
      link_list { 'https://www.example.com, https://www.test.com' }
    end

    trait :team do
      team
    end

    trait :user do
      user
    end

    factory :slack_thread_with_reply_users do
      team
      reply_users do
        create_list(:user, 2, team: team).map(&:id).join(', ')
      end
      reply_users_count { 2 }
    end
  end
end
