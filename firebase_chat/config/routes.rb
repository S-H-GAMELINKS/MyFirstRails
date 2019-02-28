Rails.application.routes.draw do
  root 'rooms#index'
  resources :rooms
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
