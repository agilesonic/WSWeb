WSWeb::Application.routes.draw do
  get "online_services/index"

  get "user/login"
  
  post "user/process_login"

  get "user/register"

  get "user/register_confirm"

  get "user/forgot_password"

  get "user/forgot_password_confirm"

  root :to => 'home#index'
  
  resources  :services,     :only => ['index']
  resources  :inquiries #,       :only => ['create', 'confirm']

end
