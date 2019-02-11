Rails.application.routes.draw do
  root 'web#index'
  namespace :api, format: 'json' do
    resources :accounts
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
