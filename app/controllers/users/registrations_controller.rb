class Users::RegistrationsController < ApplicationController
  def new
    @registration_form = RegistrationForm.new
    render :registration
  end
  
  def create
    @registration_form = RegistrationForm.new(params[:registration_form])
    if @registration_form.valid? 
      client = get_client
      if !client.nil? && @registration_form.valid?
        register_user client
        Utils.log 'User regitration succeeded. CFID: ' + client.CFID + ' email: ' + @registration_form.email
        render :registration_confirm
      else
        Utils.log @registration_form.errors[''].first
        render :registration
      end
    else
      render :registration
    end
  end
  
  private
  
  def get_client
    client = nil
    if WebUser.by_email(@registration_form.email).nil?
      clients = Client.search(@registration_form.phone)
      if !clients.nil? && !clients.empty?
        clients.each do |c|
          if c.valid? && !c.lastname.nil? && c.full_name != "New Home Owner" && c.postcode == Utils.format_postal_code(@registration_form.postal_code)
            names = c.lastname.split('/')
            names.each do |name|
              if name.casecmp(@registration_form.last_name) == 0
                if client.nil?
                  client = c
                else
                  @registration_form.errors[''] << 'We cannot find an account matches the criteria.'
                end
              end
            end 
          end          
        end
        if client.nil?
          @registration_form.errors[''] << 'We cannot find an account matches the criteria.'
        end
        if !WebUser.by_client_id(client.CFID).nil?
          @registration_form.errors[''] << "You have already registered, if you forgot your password, please <a href='" + new_users_forgot_password_path + "'>click here</a>"
        end
      else
        @registration_form.errors[''] << 'We cannot find an account matches the criteria.'
      end
    else
      @registration_form.errors[''] << "You have already registered, if you forgot your password, please <a href='" + new_users_forgot_password_path + "'>click here</a>"
    end
    return client
  end
  
  def register_user(client)
    user = WebUser.new
    user.id = Utils.next_id(WebUser.maximum('id'))
    user.email = @registration_form.email.downcase.strip
    user.password = client.CFID
    user.active = true
    user.client = client
    user.create_date = DateTime.now
    user.modify_date = user.create_date
    user.save!

    client.email = user.email
    client.save!
    
    AppMailer.user_registration_mail(user).deliver

  end
  
end