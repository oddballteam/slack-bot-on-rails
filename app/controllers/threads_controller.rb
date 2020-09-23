class ThreadsController < ApplicationController
  def index
    respond_to do |format|
      format.json { render json: slack_threads }
      format.html do
        render component: 'threads/List',
              #  props: MapSerializer.render_as_hash(map),
               tag: 'div',
               prerender: false
      end
    end
  end

  def show
    respond_to do |format|
      format.json { render json: slack_thread }
      format.html do
        render component: 'threads/Edit',
               props: { item: slack_thread.attributes },
               tag: 'div',
               prerender: false
      end
    end
  end

  private

  def slack_thread
    @slack_thread ||= SlackThread.find(params[:id])
  end

  def slack_threads
    from = params[:from]
    to = params[:to]

    query = SlackThread.all
    query = query.after(from) unless from.blank?
    query = query.before(to) unless to.blank?
    query
  end
end
