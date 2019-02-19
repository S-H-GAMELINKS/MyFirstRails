Rails.application.routes.draw do
  root 'novels#index'
  resources :novels do
    resources :comments, :only => [:create, :destroy]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
