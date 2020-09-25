# frozen_string_literal: true

Rails.application.routes.draw do
  resources :teams, only: %i[index new create]
  resources :threads, only: %i[index show]
end
