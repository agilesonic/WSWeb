class Client < ActiveRecord::Base
  self.table_name="cfinfo"

  #attr_accessible :company, :honorific, :firstname, :lastname, :address, :city, :province, :postcode, :perly, :phone, 
   #             :cellphone, :offphone, :fax, :email

  has_many :clientcontacts, :foreign_key => "cfid", :conditions=>"dateatt>'2012-10-01'", :inverse_of => :client
  has_many :properties, :foreign_key => "cfid", :inverse_of => :client
  has_many :valid_properties, :class_name => "Property", :foreign_key => "cfid", :conditions => "validuntil is null or validuntil = \'\'"
  has_many :jobs, :through => :properties
  has_many :done_jobs, :class_name => "Job", :through => :properties, :conditions => "datebi is not null", :order=>"datebi desc", :source => :jobs
  has_many :done_jobs_2013, :class_name => "Job", :through => :properties, :conditions => "datebi>='2013-01-01'", :order=>"datebi desc", :source => :jobs
  has_many :upcoming_jobs, :class_name => "Job", :through => :properties, :conditions => "sdate is not null and datebi is null", :order=>"sdate", :source => :jobs
  
  def self.search(key) 
    where("lastname like ? or firstname like ? or address like ? or phone like ?", "%#{key}%", "%#{key}%", "%#{key}%", "%#{key}%").order("lastname, firstname") 
  end


#  @clients=Client.search1(@shortname, @address, @phone, @jobaddress, @cfid, @jobid)
  
  def self.search1(key1, key2, key3, key4, key5, key6)
    Client.joins(:properties).joins(:jobs).where("(cfinfo.lastname like ? or cfinfo.firstname like ? or cfinfo.address like ? or 
    cfjobinfo.address like ? or cfinfo.phone like ? or cfinfo.address like ? or cfjobinfo.address like ? or 
    cfinfo.CFID = ?  or jobs.jobid = ?) and cfinfo.validuntil is null",
     "%#{key1}%", "%#{key1}%", "%#{key2}%", "%#{key2}%", "%#{key3}%", "%#{key4}%", "%#{key4}%", "#{key5}", "#{key6}").order("lastname, firstname") 
  end


  def self.search_cfrange(key1, key2) 
    where("cfid between ? and ?", "#{key1}", "#{key2}").order("cfid") 
  end

  def self.search_kbanger(key1) 
    where("mgr = ? and validuntil is null", "#{key1}").limit("10") 
  end


  def full_name
    s = ''
    s << honorific + ' ' unless honorific.nil?
    s << firstname + ' ' unless firstname.nil?
    s << lastname unless lastname.nil?
    s.strip
  end
end
