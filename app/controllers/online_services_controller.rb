class OnlineServicesController < ApplicationController
  def index
    if session[:user_email].nil?
      redirect_to login_path
    else
      @user = web_user
    end
  end
end
