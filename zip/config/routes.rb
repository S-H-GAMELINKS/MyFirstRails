Rails.application.routes.draw do
  root 'zipfiles#index'
  get 'web/index'
  resources :zipfiles, :only => [:index, :create]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end