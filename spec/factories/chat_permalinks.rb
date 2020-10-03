# frozen_string_literal: true

FactoryBot.define do
  factory :chat_permalink, class: OpenStruct do
    ok { true }
    channel { 'C1H9RESGA' }
    permalink { 'https://ghostbusters.slack.com/archives/C1H9RESGA/p135854651500008' }

    trait :thread do
      permalink do
        'https://ghostbusters.slack.com/archives/C1H9RESGL/p135854651700023?thread_ts=1358546515.000008&cid=C1H9RESGL'
      end
    end

    trait :not_found do
      ok { false }
      error { 'channel_not_found' }
      channel { nil }
      permalink { nil }
    end
  end
end
