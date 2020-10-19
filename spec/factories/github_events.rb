# frozen_string_literal: true

FactoryBot.define do
  factory :github_event do
    trait :installation do
      metadata do
        {
          'action' => 'created',
          'installation' => {
            'id' => '12204791',
            'account' => {
              'login' => 'octocat',
              'id' => 12_345,
              'node_id' => 'ABC3DEFghijkLMN0',
              'avatar_url' => 'https://avatars1.githubusercontent.com/u/12345?v=4',
              'gravatar_id' => '',
              'url' => 'https://api.github.com/users/octocat',
              'html_url' => 'https://github.com/octocat',
              'followers_url' => 'https://api.github.com/users/octocat/followers',
              'following_url' => 'https://api.github.com/users/octocat/following{/other_user}',
              'gists_url' => 'https://api.github.com/users/octocat/gists{/gist_id}',
              'starred_url' => 'https://api.github.com/users/octocat/starred{/owner}{/repo}',
              'subscriptions_url' => 'https://api.github.com/users/octocat/subscriptions',
              'organizations_url' => 'https://api.github.com/users/octocat/orgs',
              'repos_url' => 'https://api.github.com/users/octocat/repos',
              'events_url' => 'https://api.github.com/users/octocat/events{/privacy}',
              'received_events_url' => 'https://api.github.com/users/octocat/received_events',
              'type' => 'User',
              'site_admin' => false
            },
            'repository_selection' => 'selected',
            'access_tokens_url' => 'https://api.github.com/app/installations/12204791/access_tokens',
            'repositories_url' => 'https://api.github.com/installation/repositories',
            'html_url' => 'https://github.com/settings/installations/12204791',
            'app_id' => 83_447,
            'app_slug' => 'va.gov-support-slackbot',
            'target_id' => 12_345,
            'target_type' => 'User',
            'permissions' => {
              'issues' => 'write',
              'metadata' => 'read',
              'pull_requests' => 'write'
            },
            'events' => %w[
              issues
              pull_request
            ],
            'created_at' => '2020-10-04T14:40:42.000-04:00',
            'updated_at' => '2020-10-04T14:40:42.000-04:00',
            'single_file_name' => nil,
            'suspended_by' => nil,
            'suspended_at' => nil
          },
          'repositories' => [
            {
              'id' => 134_017_056,
              'node_id' => 'aoeunthaoentuh=',
              'name' => 'gmusic',
              'full_name' => 'octocat/gmusic',
              'private' => false
            }
          ],
          'requester' => nil,
          'sender' => {
            'login' => 'octocat',
            'id' => 12_345,
            'node_id' => 'ABC3DEFghijkLMN0',
            'avatar_url' => 'https://avatars1.githubusercontent.com/u/12345?v=4',
            'gravatar_id' => '',
            'url' => 'https://api.github.com/users/octocat',
            'html_url' => 'https://github.com/octocat',
            'followers_url' => 'https://api.github.com/users/octocat/followers',
            'following_url' => 'https://api.github.com/users/octocat/following{/other_user}',
            'gists_url' => 'https://api.github.com/users/octocat/gists{/gist_id}',
            'starred_url' => 'https://api.github.com/users/octocat/starred{/owner}{/repo}',
            'subscriptions_url' => 'https://api.github.com/users/octocat/subscriptions',
            'organizations_url' => 'https://api.github.com/users/octocat/orgs',
            'repos_url' => 'https://api.github.com/users/octocat/repos',
            'events_url' => 'https://api.github.com/users/octocat/events{/privacy}',
            'received_events_url' => 'https://api.github.com/users/octocat/received_events',
            'type' => 'User',
            'site_admin' => false
          }
        }
      end
    end
  end
end
