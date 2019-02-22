Rails.application.routes.draw do  
  root 'web#index'
  get '/about', to: 'web#index'
  get '/category', to: 'web#index'

  get "/products", to: "web#index"
  get "/products/:id", to: "web#index"
  get "/products/:id/edit", to: "web#index"
  get "/products/new", to: "web#index"

  namespace :api, format: 'json' do
    resources :products
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end