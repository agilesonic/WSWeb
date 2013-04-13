
class Convertcalls < ActiveRecord::Base
  self.table_name="convertcalls"
  
  belongs_to :client, :foreign_key => "cfid"




  def self.search_pendings(hrid, today)
    where("hrid = ? and laststatus=? and (followup is null or followup<= ?)", "#{hrid}", "Pending", today) 
    
  end

  def self.search_profile_nocalls(lowcf, limit, hrid, today)
    where("cfid >= ? and hrid= ? and summcalls= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending')",
         "#{lowcf}","#{hrid}", "0", today).limit(limit) 
  end

  def self.search_profile_ratingsfourpointone(lowcf, limit, hrid, today)
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending') and rating>='4.1'",
         "#{lowcf}","#{hrid}", today).limit(limit) 
  end

  def self.search_profile_lastsummer(lowcf, limit, hrid, today)
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending') and numjobsls>'0'",
         "#{lowcf}","#{hrid}", today).limit(limit) 
  end
      


#    CONNECTION_OPTIONS=['No Calls', '4.1+ clients', 'Windows Last Spring', 'EH Last Spring', 'Used Us Last Year']
  def self.search_ccrange(lowcf, limit, hrid, profile, today) 
    pendings=search_pendings(hrid, today)
    profiles=[]
    if profile=='No Calls'
      profiles=search_profile_nocalls(lowcf, limit, hrid, today)
    elsif profile=='4.1+ clients'  
      profiles=search_profile_ratingsfourpointone(lowcf, limit, hrid, today)
    elsif profile=='Used Us Last Summer'  
      profiles=search_profile_lastsummer(lowcf, limit, hrid, today)
    end
    list=pendings+profiles
#    list=profiles
  end

  def self.search_unassigned
    where("hrid is null").count 
  end

  def self.search_assigned_by_holder hrid
    where("hrid=?","#{hrid}").count 
  end

  def self.available_ratingsfourpointone(lowcf, limit)
    where("cfid >= ? and hrid is null and rating>='4.1'",
         "#{lowcf}").limit(limit) 
  end

  def self.available_lastsummer(lowcf, limit)
    where("cfid >= ? and hrid is null and numjobsls>'0'",
         "#{lowcf}").limit(limit) 
  end
  
  
end