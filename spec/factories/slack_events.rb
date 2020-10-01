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
          },
          'event_time' => 1_234_567_890
        }
      end
    end

    metadata { megahash }

    trait :add_category do
      thread
      metadata do
        megahash['event'].merge!('text' => '<@BOT> add category triage')
        megahash
      end
    end

    trait :add_link do
      thread
      metadata do
        megahash['event'].merge!('text' => '<@BOT> add link https://www.example.com')
        megahash
      end
    end

    trait :app_mention do
      metadata do
        megahash['event'].merge!('type' => 'app_mention')
        megahash
      end
    end

    trait :categories do
      thread
      metadata do
        megahash['event'].merge!('text' => '<@BOT> categories')
        megahash
      end
    end

    trait :close do
      thread
      metadata do
        megahash['event'].merge!('text' => '<@BOT> close')
        megahash
      end
    end

    trait :help do
      thread
      metadata do
        megahash['event'].merge!('text' => '<@BOT> help')
        megahash
      end
    end

    trait :link do
      thread
      metadata do
        megahash['event'].merge!('text' => '<@BOT> link https://www.example.com')
        megahash
      end
    end

    trait :links do
      thread
      metadata do
        megahash['event'].merge!('text' => '<@BOT> links')
        megahash
      end
    end

    trait :list_categories do
      thread
      metadata do
        megahash['event'].merge!('text' => '<@BOT> list categories')
        megahash
      end
    end

    trait :list_links do
      thread
      metadata do
        megahash['event'].merge!('text' => '<@BOT> list links')
        megahash
      end
    end

    trait :remove_category do
      thread
      metadata do
        megahash['event'].merge!('text' => '<@BOT> remove category triage')
        megahash
      end
    end

    trait :remove_link do
      thread
      metadata do
        megahash['event'].merge!('text' => '<@BOT> remove link https://www.test.com')
        megahash
      end
    end

    trait :resolve do
      thread
      metadata do
        megahash['event'].merge!('text' => '<@BOT> resolve')
        megahash
      end
    end

    trait :thread do
      app_mention
      metadata do
        megahash['event'].merge!('thread_ts' => '1515449522000008')
        megahash
      end
    end

    trait :track do
      thread
      metadata do
        megahash['event'].merge!('text' => '<@BOT> track')
        megahash
      end
    end

    trait :unlink do
      thread
      metadata do
        megahash['event'].merge!('text' => '<@BOT> unlink https://www.test.com')
        megahash
      end
    end
  end
end
