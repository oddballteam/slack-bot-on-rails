# frozen_string_literal: true

FactoryBot.define do
  factory :slack_event do
    metadata { '' }

    trait :app_mention do
      metadata do
        {
          "type": 'app_mention',
          "user": 'U061F7AUR',
          "text": '<@U0LAN0Z89> is it everything a river should be?',
          "ts": '1515449522.000016',
          "channel": 'C0LAN2Q65',
          "event_ts": '1515449522000016'
        }.to_json
      end
    end
  end
end
