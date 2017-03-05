Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "houses#index"
  resources :regions, only: %w{show}
  resources :houses, only: %w{index show}
end
