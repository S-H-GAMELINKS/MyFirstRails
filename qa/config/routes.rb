Rails.application.routes.draw do
  devise_for :users
  resources :categories
  root 'questions#index'
  resources :questions do
    resources :comments, :only => [:edit, :create, :update, :destroy]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
