class RegistrationForm < BaseForm
  
  attr_accessor :last_name, :postal_code, :email, :phone
  
  validates_presence_of :last_name, :postal_code, :email, :phone
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i, :unless => "email.empty?"
  
end