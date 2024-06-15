Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users
      resources :authntications do
        collection do
          post 'login'
          delete 'logout'
        end
      end
    end
  end
end
