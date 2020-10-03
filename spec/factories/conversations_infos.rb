# frozen_string_literal: true

FactoryBot.define do
  factory :_conversations_info_public, class: OpenStruct do
    id { 'C012AB3CD' }
    name { 'general' }
    is_channel { true }
    is_group { false }
    is_im { false }
    created { 1_449_252_889 }
    creator { 'W012A3BCD' }
    is_archived { false }
    is_general { true }
    unlinked { 0 }
    name_normalized { 'general' }
    is_read_only { false }
    is_shared { false }
    parent_conversation { nil }
    is_ext_shared { false }
    is_org_shared { false }
    pending_shared { [] }
    is_pending_ext_shared { false }
    is_member { true }
    is_private { false }
    is_mpim { false }
    last_read { '1502126650.228446' }
  end

  factory :_conversations_info_im, class: OpenStruct do
    id { 'C012AB3CD' }
    created { 1_507_235_627 }
    is_im { true }
    is_org_shared { false }
    user { 'U27FFLNF4' }
    last_read { '1513718191.000038' }
    latest do
      {
        "type": 'message',
        "user": 'U5R3PALPN',
        "text": 'Psssst!',
        "ts": '1513718191.000038'
      }
    end
    unread_count { 0 }
    unread_count_display { 0 }
    is_open { true }
    locale { 'en-US' }
  end

  factory :conversations_info, class: OpenStruct do
    ok { true }
    channel do
      build(:_conversations_info_public)
    end

    trait :im do
      channel do
        build(:_conversations_info_im)
      end
    end

    trait :not_found do
      ok { true }
      error { 'channel_not_found' }
      channel { nil }
    end
  end
end
