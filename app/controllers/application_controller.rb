require File.expand_path('../../utils/Utils', __FILE__)

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def web_user
    WebUser.by_email(session[:user_email])
  end

  
end
