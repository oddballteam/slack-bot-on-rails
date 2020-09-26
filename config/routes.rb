# frozen_string_literal: true

Rails.application.routes.draw do
  resources :teams, only: %i[index new]
  # slack pingback to create team
  get '/teams/create', to: 'teams#create', as: 'create_team'
  resources :threads, only: %i[index show]
end
