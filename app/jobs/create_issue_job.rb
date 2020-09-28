# frozen_string_literal: true

# - create github issue
#   - if there is no github auth yet, or if create issue fails, post an error to slack re: how to fix
# - state: ticketed
# - post update to Slack with link to github ticket
#   - hype how this process helps us to solve 100% of issues via documentation?
class CreateIssueJob < ApplicationJob
end
