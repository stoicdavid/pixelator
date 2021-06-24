Rails.application.routes.draw do
  get 'variations/show'
  get 'variations/destroy'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  resources :pictures
  get "welcome/index"  
  root to: "welcome#index"  
  
  resources :variations
  get '/variations/:id/html_image', to: 'variations#html_image', as: 'html_image'
  
end
