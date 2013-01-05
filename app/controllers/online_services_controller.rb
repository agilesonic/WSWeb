class OnlineServicesController < ApplicationController
  def index
    if session[:user_email].nil?
      redirect_to :controller => 'user', :action => 'login'
    end
  end
end
