class AppMailer < ActionMailer::Base
  default :from => "customerservice@whiteshark.ca"
 
  def inquiry_mail(inquiry_form)
    @inquiry_form = inquiry_form
    mail(:from => "mainsrv@whiteshark.ca", :to => "customerservice@whiteshark.ca", :subject => "Client online inquiry")
  end
  
  def forgot_password_mail(forgot_password_form, user)
    @forgot_password_form = forgot_password_form
    @user = user
    mail(:to => @user.email, :subject => "White Shark Online Services Password")
  end
  
  def user_registration_mail(user)
    @user = user
    mail(:to => @user.email, :subject => 'Welcome to White Shark Online Services')
  end
  
  def send_estimate_mail(client)
    @client = client
    puts 'EMAILSES ',@client.email
    mail(:to => @client.email, :subject => 'White Shark Estimate For Windows/Eaves')
  end
  

end
