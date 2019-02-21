Rails.application.routes.draw do
  devise_for :users
  resources :users, :only => [:show, :edit, :update]
  root 'movies#index'
  resources :movies do
    resources :comments, :only => [:create, :destroy]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
