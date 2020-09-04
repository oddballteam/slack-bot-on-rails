class MessagesController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json { render json: messages }
    end
  end

  private

  def messages
    (1..10).map do |i|
      { id: i, message: Rails.cache.read(i) }
    end
  end
end
