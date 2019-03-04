Rails.application.routes.draw do
  root 'rooms#index'
  resources :rooms do
    resources :talks, :only => [:index, :create]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
