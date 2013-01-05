class UserController < ApplicationController
  def login
    @login_form = LoginForm.new
  end
  
  def process_login
    @login_form = LoginForm.new(params[:login_form])
    if @login_form.valid?
      session[:user_email] = @login_form.email
      redirect_to :controller => :online_services, :action => :index
    else
      render :login
    end
  end

  def register
  end

  def register_confirm
  end

  def forgot_password
  end

  def forgot_password_confirm
  end
end
