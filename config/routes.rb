Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"

      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"
      delete "auth/logout", to: "auth#logout"
      post "auth/refresh", to: "auth#refresh"

      get "me", to: "me#show"

      resources :categories, only: [ :index ]
      resources :products, only: [ :index, :show ], param: :slug

      get "cart", to: "cart#show"
      resources :cart_items, only: [ :create, :update, :destroy ], path: "cart/items"

      resources :orders, only: [ :index, :show, :create ]
      post "payments/verify", to: "payments#verify"
      post "payments/failed", to: "payments#failed"

      namespace :manager do
        resources :categories, only: [ :create, :update, :destroy ]

        resources :products, only: [ :create, :update ] do
          member do
            patch :deactivate
          end

          resources :images, controller: "product_images", only: [ :create, :update, :destroy ]
        end
      end

      namespace :admin do
        resources :orders, only: [ :index, :show ] do
          member do
            patch :status
          end

          collection do
            get :receipts
            get :abandoned
          end
        end
      end
    end
  end
end
