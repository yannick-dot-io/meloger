Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "regions#index"
  resources :regions, only: %w{index show}
  resources :houses, only: %w{show}
end
