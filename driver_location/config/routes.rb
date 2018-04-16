Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  constraints format: /(json)/ do
    resources :drivers, only: [] do
      member do
        get :coordinates
      end
    end
  end
end
