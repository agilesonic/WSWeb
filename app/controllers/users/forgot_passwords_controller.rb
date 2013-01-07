class Users::ForgotPasswordsController < ApplicationController
  def new
  	@forgot_password_form = ForgotPasswordForm.new
    render :forgot_password
  end
  
  def create
  	@forgot_password_form = ForgotPasswordForm.new(params[:forgot_password_form])
	@user = WebUser.by_email(@forgot_password_form.email)
    if @forgot_password_form.valid?
      AppMailer.forgot_password_mail(@forgot_password_form, @user).deliver
      render :forgot_password_confirm
    else
      render :forgot_password
    end
  end
  
end