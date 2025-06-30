Rails.application.routes.draw do
  # Home page
  root 'pages#home'
  
  # Users resource with all CRUD actions
  resources :users do
    member do
      get :profile
    end
  end
  
  # About page
  get 'about', to: 'pages#about'
  
  # Contact page
  get 'contact', to: 'pages#contact'
end 