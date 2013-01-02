class InquiryMailer < ActionMailer::Base
  default :from => "customerservice@whiteshark.ca"
 
  def inquiry_mail(inquiry)
    @inquiry = inquiry
    mail(:from => "mainsrv@whiteshark.ca", :to => "customerservice@whiteshark.ca", :subject => "Client online inquiry")
  end
  
end
