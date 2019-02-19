Rails.application.routes.draw do
  root 'novels#index'
  resources :novels
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
