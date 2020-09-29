# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    slack_id { 'MyString' }
    display_name { 'MyString' }
    real_name { 'MyString' }
    image_url { 'MyString' }
  end

  trait :team do
    team
  end
end
