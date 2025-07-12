Rails.application.routes.draw do
  # Mount VibeErrors engine
  mount VibeErrors::Engine => '/vibe_errors'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "application#index"
  
  # Demo routes for testing VibeErrors
  post "simulate_error", to: "application#simulate_error"
  post "log_message", to: "application#log_message"
end
