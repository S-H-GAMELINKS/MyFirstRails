Rails.application.routes.draw do
  namespace :api do
    resources :products
  end
  root 'web#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
