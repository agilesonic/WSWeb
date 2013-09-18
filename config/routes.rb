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
  
  resources :crews do
    collection do
      get 'tracker'
    end
    member do
      get 'activity'
    end
  end


  resources :employees do
    collection do
      get 'verpay'
      get 'showindpay'
      get 'showrangepay'
      post 'indpay'
      get 'rangepay'
      get 'deletepay'
      post 'createpay'
      get 'back_verpay'
      get 'back_rangepay'
    end
    member do
      get 'recordpay'
      post 'savepay'
      get 'deletepay'
    end
  end

 
  resources :functions do
    collection do
      post 'savedatacheck'
      post 'datacheck' 
      get 'showdatacheck' 
      get 'send_estimate_mail'
      get 'loginuser'
      post 'logoutuser'
      get 'login'
      post 'login'
      post 'findclients'   # /clients/count   helper_method: count_clients_path
      get 'smartsearch'
      get 'messagelog'
      get 'logmessage'
      post 'screenmessage'
      get 'loadsatisfaction'
      post 'satisfaction'
      get 'satisfaction1'
      get 'nextsat'
      get 'login1'
      get 'co_stats'
      get 'co_stats_septoct'
      get 'co_stats_novdec'
      get 'ind_stats'
      get 'ind_stats_7'
      get 'stats1'
      get 'stats_schedule'
      get 'stats_production'
      get 'new'
      get 'send_estimate_mail'
      get 'kill_stats'
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
      post 'calllog5'
      get 'newcalllog5'
      get 'schedule'
      get 'clientlist'
      get 'nextbatch'
      get 'findclients'
      get 'callprofile' 
      post 'searchclients'
      post 'assclients' 
      post 'callprofile1'
      get 'screenconvertcalls' 
      get 'screensales' 
      post 'actionclients'
      get 'saleshistory'
      get 'schedule'
      get 'calllog'
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
      get 'previousclient'
      get 'deletecontact'
      get 'deletesale'
    end
  end
  
end
