FactoryBot.define do
  factory :slack_command, class:OpenStruct do
    channel { 'ABCDEF0123456789' }
    thread_ts { '1599245993.010500' }
    ts { '1599247956.016900' }
  end
end
