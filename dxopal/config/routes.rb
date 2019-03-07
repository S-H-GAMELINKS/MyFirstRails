Rails.application.routes.draw do
  resources :codes
  get '/codes/:id/code', to: 'codes#code'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
