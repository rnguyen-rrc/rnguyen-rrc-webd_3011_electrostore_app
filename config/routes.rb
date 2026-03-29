Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get "up" => "rails/health#show", as: :rails_health_check

  resources :products, only: [:index, :show]
  resources :categories, only: [:index, :show]

  root "products#index"
end