# frozen_string_literal: true

# record events from the Slack Events API, for future processing
class EventsController < ApplicationController
  def create
    render json: { challenge: params[:challenge] } if url_verification?
  end

  private

  def url_verification?
    params[:type] == 'url_verification' && params[:challenge].present?
  end
end
