Rails.application.routes.draw do
  root "rails/welcome#index"
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :users
      resources :groups
      resources :authentications do
        collection do
          post :login
          delete :logout
        end
      end
    end
  end
end
