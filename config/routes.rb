Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :users
      resources :authentications do
        collection do
          post :login
        end
      end
    end
  end
end
