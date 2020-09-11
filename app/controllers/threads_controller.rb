class ThreadsController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json { render json: slack_threads }
    end
  end

  private

  def slack_threads
    from = params[:from]
    to = params[:to]

    query = SlackThread.all
    query = query.after(from) unless from.blank?
    query = query.before(to) unless to.blank?
    query
  end
end
