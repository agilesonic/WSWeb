class Client < ActiveRecord::Base
  set_table_name "cfinfo"
  has_many :properties, :foreign_key => "cfid", :inverse_of => :client
  has_many :valid_properties, :class_name => "Property", :foreign_key => "cfid", :conditions => "validuntil is null or validuntil = \'\'"
  has_many :jobs, :through => :properties
  has_many :done_jobs, :class_name => "Job", :through => :properties, :conditions => "datebi is not null", :source => :jobs
  
  def self.search(key) 
    where("lastname like ? or firstname like ? or address like ? or phone like ?", "%#{key}%", "%#{key}%", "%#{key}%", "%#{key}%").order("lastname, firstname") 
  end

  def full_name
    s = ''
    s << honorific + ' ' unless honorific.nil?
    s << firstname + ' ' unless firstname.nil?
    s << lastname unless lastname.nil?
    s.strip
  end
end
