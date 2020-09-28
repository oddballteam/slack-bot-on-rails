# frozen_string_literal: true

# record events from the Slack Events API, for future processing
class EventsController < ApplicationController
  skip_forgery_protection only: %i[create]

  def create
    if url_verification?
      render json: { challenge: params[:challenge] }
    else
      event = SlackEvent.new(metadata: params.permit!)
      if event.save
        event.enqueue_job
        head :created
      else
        head :unprocessable_entity
      end
    end
  end

  private

  def url_verification?
    params[:type] == 'url_verification' && params[:challenge].present?
  end
end
