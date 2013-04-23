class Clientcontact < ActiveRecord::Base
  set_table_name "cfcontact"

  belongs_to :client, :foreign_key => "cfid"

  def self.search_cfcontacts(key1) 
    where("cfid = ? ", "#{key1}").order("dateatt") 
  end

 def self.num_cfcontacts_summer2013(key1) 
    where("cfid = ? and dateatt between '2013-04-01' and '2013-08-31'", "#{key1}").count 
 end

 def self.num_cfcontacts_summer2013_ind(key1) 
    where("caller = ? and dateatt between '2013-04-01' and '2013-08-31'", "#{key1}").count 
 end

 def self.num_cfcontacts_summer2013_ind_curr(key1, date) 
    where("caller = ? and dateatt = ?", "#{key1}", date).count 
 end


 def self.num_cfcontacts_fall2013(key1) 
    where("cfid = ? and dateatt between '2013-09-01' and '2013-12-31'", "#{key1}").count 
 end

end
