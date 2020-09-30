# frozen_string_literal: true

FactoryBot.define do
  factory :slack_thread do
    channel { 'ABC123' }
    latest_reply_ts { '1601259545.009300' }
    reply_count { Faker::Number.within(range: 1..10) }
    reply_users { 'Bobby Tables, Slackbot' }
    reply_users_count { 2 }
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
  end
end
