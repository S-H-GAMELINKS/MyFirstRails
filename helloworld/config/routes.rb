Rails.application.routes.draw do
  root 'web#hello'
  get 'web/hello'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
