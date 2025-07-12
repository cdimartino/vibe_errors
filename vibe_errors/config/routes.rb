VibeErrors::Engine.routes.draw do
  # Health check endpoint
  get 'health', to: 'health#index'
  
  # API Routes
  namespace :api do
    resources :errors do
      member do
        patch :resolve
        patch :assign_owner
        post :add_tag
        delete :remove_tag
      end
      collection do
        post :create_from_exception
      end
    end

    resources :messages do
      member do
        post :add_tag
        delete :remove_tag
      end
      collection do
        post :create_from_content
      end
    end

    resources :tags do
      collection do
        get :popular
      end
    end

    resources :owners, only: [:index, :show, :create, :update, :destroy]
    resources :teams, only: [:index, :show, :create, :update, :destroy]
    resources :projects, only: [:index, :show, :create, :update, :destroy]
  end

  # Web Interface Routes
  root "dashboard#index"

  resources :errors do
    member do
      patch :resolve
      patch :assign_owner
      post :add_tag
      delete :remove_tag
    end
  end

  resources :messages do
    member do
      post :add_tag
      delete :remove_tag
    end
  end

  resources :tags, only: [:index, :show, :create, :update, :destroy]
  resources :owners, only: [:index, :show, :create, :update, :destroy]
  resources :teams, only: [:index, :show, :create, :update, :destroy]
  resources :projects, only: [:index, :show, :create, :update, :destroy]

  get :dashboard, to: "dashboard#index"
  get :search, to: "search#index"
end
