class Clientcontact < ActiveRecord::Base
  set_table_name "cfcontact"

  belongs_to :client, :foreign_key => "cfid"

  def self.search_cfcontacts(key1) 
    where("cfid = ? ", "#{key1}").order("dateatt") 
  end

  def self.calllog(hrid,today) 
    where("caller = ? and dateatt= ? ", "#{hrid}", today).uniq.order("callmade") 
  end



  def self.callers 
    #where("datesold between ? and ?", date1, date2)
    #find_by_sql("select distinct(salesid1) from jobs where datesold>'2013-04-01'").pluck(:salesid1) 
    where("dateatt>'2013-04-01' and caller not in ('HR00000639', 'HR00000001')").uniq.pluck(:caller) 
    #where("dateatt>'2013-04-01'").pluck(:caller) 
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
