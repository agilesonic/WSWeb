WSWeb::Application.routes.draw do
  get 'home/index'
  get 'home/contactUs'
  
  root :to => 'home#index'

end
