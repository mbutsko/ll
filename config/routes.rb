Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]

  get "up" => "rails/health#show", as: :rails_health_check

  resources :metrics, except: [:show]

  get  "measurements/:metric_slug", to: "measurements#index", as: :measurement
  post "measurements/:metric_slug", to: "measurements#create", as: :measurements

  post "api_token/regenerate", to: "api_tokens#regenerate", as: :regenerate_api_token

  namespace :api do
    resources :metrics, only: [:create]
    resources :measurements, only: [:create]
  end

  root "home#index"
end
