Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]

  get "up" => "rails/health#show", as: :rails_health_check

  resources :metrics, except: [:show]

  get   "measurements/new",      to: "measurements#new",         as: :new_measurement
  get   "measurements/:id/edit", to: "measurements#edit",        as: :edit_measurement
  patch "measurements/:id",      to: "measurements#update",      as: :update_measurement
  post  "measurements",          to: "measurements#full_create", as: :create_measurement

  get  "measurements/:metric_slug", to: "measurements#index", as: :measurement
  post "measurements/:metric_slug", to: "measurements#create", as: :measurements

  post "api_token/regenerate", to: "api_tokens#regenerate", as: :regenerate_api_token

  namespace :api do
    resources :metrics, only: [:create] do
      collection do
        get :search
      end
    end
    resources :measurements, only: [:create]
  end

  root "home#index"
end
