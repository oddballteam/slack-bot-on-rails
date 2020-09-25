Rails.application.routes.draw do
  resources :teams, only: [:index, :create]
  resources :threads, only: [:index, :show]
end
