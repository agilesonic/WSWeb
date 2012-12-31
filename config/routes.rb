WSWeb::Application.routes.draw do
  get 'home/contactUs'
  
  root :to => 'home#index'
  
  resources  :services #,     :only => ['show']

end
