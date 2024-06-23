Rails.application.routes.draw do
  root "rails/welcome#index"
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :users
      resources :groups
      resources :group_users do
        collection do
          post :invite
          post :accept
        end
      end
      resources :authentications do
        collection do
          post :login
          delete :logout
          post :signup
        end
      end
    end
  end
end
