class Users::SessionsController < ApplicationController
  def new
    @login_form = LoginForm.new
    render :login
  end
  
  def create
    @login_form = LoginForm.new(params[:login_form])
    if @login_form.valid?
      if !WebUser.by_email(@login_form.email).nil?
        session[:user_email] = @login_form.email
        redirect_to online_services_path
      else
        login_form.errors[''] << 'The login info does not match our record.'
        render :login
      end
    else
      render :login
    end
  end
  
  def destroy
    session[:user_email] = nil
    redirect_to login_path
  end
end