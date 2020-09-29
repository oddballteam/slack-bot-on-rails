# frozen_string_literal: true

FactoryBot.define do
  factory :_slack_user_profile, class: OpenStruct do
    display_name { 'Bobby Tables' }
    image_72 { 'https://www.test.com/image.jpg' }
    real_name { 'The Most Groovy Bobby Tables' }
  end

  factory :slack_user_profile, class: OpenStruct do
    ok { true }
    profile { build(:_slack_user_profile) }
  end
end
