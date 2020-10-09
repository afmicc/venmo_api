Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :users, only: %i[show create] do
        scope module: :users do
          resources :friendships, only: :create
          resources :payments, only: :create
        end
      end
    end
  end
end
