# frozen_string_literal: true

module ApplicationHelper
  # render view
  def render(template, locals = {})
    ApplicationController.render(template: template, layout: nil, locals: locals)
  end
end
