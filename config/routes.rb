Rails.application.routes.draw do
  resources :threads, only: [:index, :show]
end
