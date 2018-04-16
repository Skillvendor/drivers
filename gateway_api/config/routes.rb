Rails.application.routes.draw do
  constraints format: /(json)/ do
    resources :drivers, only: [:update, :show]
  end
end
