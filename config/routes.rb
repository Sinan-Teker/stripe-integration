Rails.application.routes.draw do

  resources :products
  
  get "kayit", to: "kayit#new"
  post "kayit", to: "kayit#create"
  delete "erase", to: "kayit#destroy"

  get "giris", to: "sessions#new"
  post "giris", to: "sessions#create"

  delete "cikis", to: "sessions#destroy"

  post "products/add_to_cart/:id", to: "products#add_to_cart", as: "add_to_cart"
  delete "products/remove_from_cart/:id", to: "products#remove_from_cart", as: "remove_from_cart"

  get "buy", to: "buy#new"
  post "buy", to: "buy#create"

  get "/payment", to: "payment#index", as: :payment
  get "/card/new", to: "payment#new_card", as: :add_payment_method
  post "/card", to: "payment#create_card", as: :create_payment_method

  get "subscription", to: "subscription#new"
  post "/subscription", to: "subscription#subscribe", as: :subscribe

  root to: "home#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end