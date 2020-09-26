# frozen_string_literal: true

FactoryBot.define do
  factory :oauth, class: OpenStruct do
    access_token { 'xoxb-1234567' }
    bot_user_id { 'U0KRQLJ9H' }
    team do
      {
        'name' => 'Slack Softball Team',
        'id' => 'T9TK3CUKW'
      }
    end
    authed_user do
      {
        'id' => 'U1234',
        'access_token' => 'xoxp-1234'
      }
    end
  end
end
