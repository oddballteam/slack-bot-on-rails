# frozen_string_literal: true

FactoryBot.define do
  factory :slack_reply, class: OpenStruct do
    blocks { [] }
    latest_reply { '1601259545.006300' }
    reply_count { 14 }
    reply_users { %w[U01A1628SLV U0132PA923R] }
    reply_users_count { 2 }
    subscribed { false }
    team { 'T1ZD0BB1E' }
    text { '<@UBOT1905SAV> track it now' }
    thread_ts { '1601259399.003500' }
    ts { '1601259399.003500' }
    type { 'message' }
    user { 'U0132PA923R' }
  end

  factory :slack_replies, class: OpenStruct do
    messages do
      [
        build(:slack_reply)
      ]
    end
  end
end
