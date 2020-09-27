# frozen_string_literal: true

FactoryBot.define do
  factory :slack_event do
    transient do
      megahash do
        {
          'event' => {
            'user' => 'U061F7AUR',
            'text' => '<@U0LAN0Z89> is it everything a river should be?',
            'ts' => '1515449522.000016',
            'channel' => 'C0LAN2Q65',
            'event_ts' => '1515449522000016',
            'team' => 'T1ZD0UBMZ'
          }
        }
      end
    end

    metadata { megahash }

    trait :app_mention do
      metadata do
        megahash['event'].merge!('type' => 'app_mention')
        megahash
      end
    end

    trait :thread do
      metadata do
        megahash['event'].merge!('thread_ts' => '1515449522000008')
        megahash
      end
    end
  end
end
