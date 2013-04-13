WSWeb::Application.routes.draw do
  get "online_services/index"
  
  #match 'login'   => 'users/sessions#new'
  #match 'login'   => 'functions/login'

  match 'logout'  => 'users/sessions#destroy'
  match 'signup'  => 'users/registrations#new'
  
  namespace :users do
    resources :sessions,          :only => [:new, :create, :destroy]
    resources :forgot_passwords,  :only => [:new, :create]
    resources :registrations,     :only => [:new, :create]
    resources :profiles,          :only => [:new, :create]
  end


  root :to => 'functions#new'
  
  resources  :services,           :only => ['index']
  resources  :online_services,    :only => ['index']
  resources  :inquiries,          :only => ['new', 'create']

  #match "/sales/loadclients" => "sales#loadclients"
  #match "/sales/callclient1" => "sales#callclient1"
  #match "/functions/messages" => "functions#messages"
  
 
  resources :functions do
    collection do 
      get 'login'
      post 'login'
      post 'findclients'   # /clients/count   helper_method: count_clients_path
      get 'smartsearch'
      get 'messagelog'
      get 'logmessage'
      post 'screenmessage'
      get 'satisfaction'
    end
    member do
      get 'new'
      get 'clientprofile'
      post 'editclient'
      get 'makednf'
      post 'makednffromcfdetails'
      get 'modifydnf'
      post 'savemodifydnf'
      post 'savesatcall'
      get 'nextsatclient'
      get 'satisfaction_from_client_profile'
    end
  end
  resources :functions
  
  
  
  resources :sales do
    collection do 
      post 'loadclients'   # /clients/count   helper_method: count_clients_path
      get 'index'
      get 'schedule'
      get 'clientlist'
      get 'nextbatch'
      get 'findclients' 
      post 'searchclients'
      post 'assclients' 
    end
    member do
#      get 'loadclient'  # /clients/:id/changeAddress   helper_method: changeAddress_client_path(:id)
      get 'callclient'
      post 'callclient1'
      get 'makesale'
      post 'makesale1'
      post 'makesalefromcfdetails'
      post 'savemodifysale'
      get 'modifysale'
      get 'nextclient'
    end
  end
  #resources :sales
  
end
