class Users::ProfilesController < ApplicationController
  def new
    @profile_form = ProfileForm.new
    @profile_form.email = web_user.email
    render :profile_update
  end
  
  def create
    @profile_form = ProfileForm.new(params[:profile_form])
    if @profile_form.valid?
      user = web_user
      if user.password == @profile_form.current_password
        user.email = @profile_form.email
        user.password = @profile_form.new_password
        user.save!
        render :profile_update_confirm
      else
        @profile_form.errors[:current_password] << 'The current password does not match our record.'
        render :profile_update
      end
    else
      render :profile_update
    end
  end
  
end