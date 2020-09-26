# frozen_string_literal: true

FactoryBot.define do
  factory :oauth, class: OpenStruct do
    access_token { 'ACC123' }
    bot { { 'bot_access_token' => 'BOT456' } }
    team_id { 'OUTLAND' }
    team_name { 'Bill The Cat' }
    user_id { 'HEINZ' }
  end
end
