Rails.application.routes.draw do
  constraints format: /(json)/ do
    resources :drivers, only: [:show]
  end
end
