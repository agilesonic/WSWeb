WSWeb::Application.routes.draw do
  root :to => 'home#index'
  
  resources  :services,     :only => ['index']
  resources  :inquiries #,       :only => ['create', 'confirm']

end
