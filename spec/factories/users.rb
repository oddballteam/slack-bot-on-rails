# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    slack_id { "U#{Faker::Alphanumeric.unique.alphanumeric(number: 8).upcase}" }
    display_name { 'bobby' }
    real_name { 'Bobby Tables' }
    image_url { 'MyString' }
  end

  trait :team do
    team
  end
end
