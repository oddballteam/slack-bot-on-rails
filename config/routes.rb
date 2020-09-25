Rails.application.routes.draw do
  resources :teams, only: [:index, :new, :create]
  resources :threads, only: [:index, :show]
end
