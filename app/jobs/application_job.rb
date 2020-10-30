# frozen_string_literal: true

# base Job class
class ApplicationJob < Que::Job
  include ApplicationHelper
end
