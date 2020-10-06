# frozen_string_literal: true

# record events from the Github Events API, for future processing
class GithubEventsController < ApplicationController
  skip_forgery_protection only: %i[create]

  def create
    record = install if params[:installation][:id]

    if record.save
      head :created
    else
      head :ok # prevent re-processing of dupe events
    end
  end

  private

  def install
    github_id = params.require(:installation).permit(:id)['id']
    metadata = params.permit!.except('action', 'controller')
    GithubInstallation.new(github_id: github_id, metadata: metadata)
  end
end
