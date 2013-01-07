class WebUser < ActiveRecord::Base
  set_table_name "webusers"
  belongs_to :client, :foreign_key => "cfid"
  
  def self.by_email(email) 
    where(:email => email).first 
  end
  
  def self.by_client_id(cfid)
    where(:CFID => cfid).first
  end
  
end