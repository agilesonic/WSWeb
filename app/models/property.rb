class Property < ActiveRecord::Base
  self.table_name= "cfjobinfo"
 
  belongs_to :client, :foreign_key => "cfid", :inverse_of => :properties
  has_many :prices, :foreign_key => "jobinfoid"

  has_many :jobs, :foreign_key => "jobinfoid"
  has_one :geocode, :foreign_key => "id"
  
  has_one :convertcalls, :foreign_key => "cfid"
  
  def self.search(key) 
    where("address like ? ", "%#{key}%").order("address") 
  end

  def self.get_client_properties(key) 
    where("cfid = ? and validuntil is null", "#{key}").order("address") 
  end

  def self.get_property_from_address(key) 
    where("address = ? and validuntil is null", "#{key}") 
  end

  def self.get_property_from_jobinfoid(key) 
    where("jobinfoid = ?", "#{key}") 
  end

end


