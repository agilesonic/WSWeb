WSWeb::Application.routes.draw do
  get "online_services/index"
  
  match 'login'   => 'users/sessions#new'
  match 'logout'  => 'users/sessions#destroy'
  match 'signup'  => 'users/registrations#new'
  
  namespace :users do
    resources :sessions,          :only => [:new, :create, :destroy]
    resources :forgot_passwords,  :only => [:new, :create]
    resources :registrations,     :only => [:new, :create]
    resources :profiles,          :only => [:new, :create]
  end

  root :to => 'home#index'
  
  resources  :services,           :only => ['index']
  resources  :online_services,    :only => ['index']
  resources  :inquiries,          :only => ['new', 'create']

end
