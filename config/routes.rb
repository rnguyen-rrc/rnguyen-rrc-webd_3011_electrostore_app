Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get "up" => "rails/health#show", as: :rails_health_check

  resources :products, only: [:index, :show]
  resources :categories, only: [:index, :show]

  get    "cart",                    to: "cart#index"
  post   "cart/add/:product_id",    to: "cart#add",    as: "add_to_cart"
  patch  "cart/update/:product_id", to: "cart#update", as: "update_cart"
  delete "cart/remove/:product_id", to: "cart#remove", as: "remove_from_cart"
  get "checkout", to: "checkout#index"
  
  resources :checkout, only: [:index, :new, :create]

  root "products#index"
end