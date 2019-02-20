Rails.application.routes.draw do
  root 'illusts#index'
  resources :illusts
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end