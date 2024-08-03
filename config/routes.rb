Rails.application.routes.draw do
  root "rails/welcome#index"
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :users
      resources :password_resets, only: [:create, :edit, :update], param: :token
      resources :groups do
        collection do
          get :invited_users
          post :participate_or_reject
        end
      end
      resources :drones, only: [:index, :create]
      resources :group_users do
        collection do
          post :invite
          post :participate_or_reject
        end
      end
      resources :flight_logs, only: [:index, :show, :create, :update, :destroy] do
        member do
          get :edit
        end
      end
      resources :authentications do
        collection do
          post :login
          delete :logout
          post :signup
        end
      end
      get 'current_location', to: 'locations#current_location'
    end
  end
end
