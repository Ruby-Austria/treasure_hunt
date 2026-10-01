Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA manifest and service worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Public pages
  get "stats", to: "stats#index", defaults: { format: :json }
  get "leaderboard", to: "leaderboard#index"

  # Authentication routes
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  # Teams
  resource :team, only: %i[show new create] do
    post :join, on: :collection
    delete :leave, on: :collection
    post :regenerate_code, on: :collection
  end

  # Dashboard (authenticated home)
  get "dashboard", to: "dashboard#index"

  # Legacy redirect
  get "home", to: redirect("/")
  resources :hunts, only: [ :show ] do
    resources :adventures, only: [ :create ]
  end
  resources :adventures, only: [ :show ] do
    member do
      post :check_location
      post :claim_clue
      post :force_claim
      post :increment_hint_usage
      delete :abandon
    end
  end

  # Admin routes
  namespace :admin do
    resources :teams, only: %i[index show]
    resources :locations
    resources :hunts
    resources :clues
    resources :attendees, only: [ :index, :new, :create, :destroy ] do
      member do
        post :unflag
      end
      collection do
        get :bulk_new
        post :bulk_create
      end
    end
    root "dashboard#index"
  end

  # Root route (must be last to avoid catching other routes)
  root "pages#index"
end
