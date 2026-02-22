Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]

  get "up" => "rails/health#show", as: :rails_health_check

  resources :metrics, except: [:show]
  resources :exercises, except: [:show]
  resources :exercise_logs, only: [:create, :destroy, :edit, :update]
  resources :foods, except: [:show]
  resources :food_logs, only: [:create, :destroy, :edit, :update]
  resources :labels, except: [:show]
  resources :journal_entries, only: [:create, :destroy, :edit, :update]

  get "stream", to: "stream#index"

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
    resources :exercise_logs, only: [:create]
    resources :food_logs, only: [:create]
    resources :journal_entries, only: [:create]
    resources :exercises, only: [] do
      collection do
        get :search
      end
    end
    resources :foods, only: [] do
      collection do
        get :search
      end
    end
  end

  root "home#index"
end
