class ThreadsController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json { render json: SlackThread.all }
    end
  end
end
