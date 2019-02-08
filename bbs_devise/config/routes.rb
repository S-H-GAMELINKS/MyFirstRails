Rails.application.routes.draw do
  resources :users, :only => [:show, :edit, :update]
  devise_for :users
  root 'posts#index'
  resources :posts do
    resources :comments, :only => [:create, :destroy]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
