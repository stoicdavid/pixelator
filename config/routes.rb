Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  resources :pictures
  get "welcome/index"  
  root to: "welcome#index"  
  
end
