Rails.application.routes.draw do
  # ------------------------
  # ADMIN (ActiveAdmin)
  # ------------------------
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # ------------------------
  # HEALTH CHECK
  # ------------------------
  get "up" => "rails/health#show", as: :rails_health_check

  # ------------------------
  # PRODUCTS & CATEGORIES
  # ------------------------
  resources :products, only: [:index, :show]
  resources :categories, only: [:index, :show]

  # ------------------------
  # CART
  # ------------------------
  get    "cart",                    to: "cart#index"
  post   "cart/add/:product_id",    to: "cart#add",    as: "add_to_cart"
  patch  "cart/update/:product_id", to: "cart#update", as: "update_cart"
  delete "cart/remove/:product_id", to: "cart#remove", as: "remove_from_cart"

  # ------------------------
  # CHECKOUT (CLEAN VERSION)
  # ------------------------
  resources :checkout, only: [:index, :new, :create] do
    collection do
      get :success
      get :cancel
    end
  end

  # ------------------------
  # PROVINCES (TAX)
  # ------------------------
  get "provinces/:id/tax", to: "provinces#tax"

  # ------------------------
  # USER AUTH (CUSTOM)
  # ------------------------
  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get  "signup", to: "users#new"
  post "signup", to: "users#create"

  post "signup_from_order/:order_id",
       to: "users#signup_from_order",
       as: :signup_from_order

  resources :users, only: [:new, :create, :edit, :update]

  # ------------------------
  # ORDERS
  # ------------------------
  resources :orders, only: [:show, :index]

  # ------------------------
  # ROOT
  # ------------------------
  root "products#index"
end