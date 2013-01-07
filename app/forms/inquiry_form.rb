class InquiryForm < BaseForm
  
  attr_accessor :name, :address, :city, :postal_code, :phone, :email, :inquiry_type, :inquiry
  
  validates_presence_of :name, :address, :city, :postal_code, :phone
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i, :unless => "email.empty?"
  
end