
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
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending') and rating between '4.0' and '4.1'",
         "#{lowcf}","#{hrid}", today).limit(limit) 
  end

  def self.search_profile_ratingsfourpointthree(lowcf, limit, hrid, today)
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending') and rating between '4.2' and '4.3'",
         "#{lowcf}","#{hrid}", today).limit(limit) 
  end

  def self.search_profile_ratingsfourpointfive(lowcf, limit, hrid, today)
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending') and rating between '4.4' and '4.5'",
         "#{lowcf}","#{hrid}", today).limit(limit) 
  end

  def self.search_profile_ratingsfourpointseven(lowcf, limit, hrid, today)
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending') and rating between '4.6' and '4.7'",
         "#{lowcf}","#{hrid}", today).limit(limit) 
  end


  def self.search_profile_lastsummer(lowcf, limit, hrid, today)
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending') and numjobsls>'0'",
         "#{lowcf}","#{hrid}", today).limit(limit) 
  end
      
  def self.count_profile_nocalls(highcf, hrid, today)
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending') and summcalls='0'",
         "#{highcf}","#{hrid}", today).count 
  end 

  def self.count_profile_ratingsfourpointone(highcf, hrid, today)
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending')  and rating between '4.0' and '4.1'",
         "#{highcf}","#{hrid}", today).count 
  end 

  def self.count_profile_ratingsfourpointthree(highcf, hrid, today)
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending')  and rating between '4.2' and '4.3'",
         "#{highcf}","#{hrid}", today).count 
  end 

  def self.count_profile_ratingsfourpointfive(highcf, hrid, today)
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending')  and rating between '4.4' and '4.5'",
         "#{highcf}","#{hrid}", today).count 
  end 

  def self.count_profile_ratingsfourpointseven(highcf, hrid, today)
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending')  and rating between '4.6' and '4.7'",
         "#{highcf}","#{hrid}", today).count 
  end 

  def self.count_profile_lastsummer(highcf, hrid, today)
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending') and numjobsls>'0'",
         "#{highcf}","#{hrid}", today).count 
  end 


  def self.count_ccrange(highcf, hrid, profile, today)
    count=0
    if profile=='No Calls'
      count=count_profile_nocalls(highcf, hrid, today)
    elsif profile=='4.0=>4.1 clients'  
      count=count_profile_ratingsfourpointone(highcf, hrid, today)
    elsif profile=='4.2=>4.3 clients'  
      count=count_profile_ratingsfourpointthree(highcf, hrid, today)
    elsif profile=='4.4=>4.5 clients'  
      count=count_profile_ratingsfourpointfive(highcf, hrid, today)
    elsif profile=='4.6=>4.7 clients'  
      count=count_profile_ratingsfourpointseven(highcf, hrid, today)
    elsif profile=='Used Us Last Summer'  
      count=count_profile_lastsummer(highcf, limit, hrid, today)
    end
    return count
  end

  def self.search_ccrange(lowcf, limit, hrid, profile, today)
    list=[]
    pendings=search_pendings(hrid, today)
    profiles=[]
    if profile=='No Calls'
      profiles=search_profile_nocalls(lowcf, limit, hrid, today)
    elsif profile=='4.0=>4.1 clients'  
      profiles=search_profile_ratingsfourpointone(lowcf, limit, hrid, today)
    elsif profile=='4.2=>4.3 clients'  
      profiles=search_profile_ratingsfourpointthree(lowcf, limit, hrid, today)
    elsif profile=='4.4=>4.5 clients'  
      profiles=search_profile_ratingsfourpointfive(lowcf, limit, hrid, today)
    elsif profile=='4.6=>4.7 clients'  
      profiles=search_profile_ratingsfourpointseven(lowcf, limit, hrid, today)
    elsif profile=='Used Us Last Summer'  
      profiles=search_profile_lastsummer(lowcf, limit, hrid, today)
    end
    if pendings.nil? && profiles.nil?
      return list
    elsif pendings.nil? && !profiles.nil?
      return profiles
    elsif !pendings.nil? && profiles.nil?
      return pendings
    elsif !pendings.nil? && !profiles.nil?
      return pendings+profiles
    else
      return list  
    end
  end

  def self.search_unassigned
    where("hrid is null").count 
  end

  def self.search_assigned_by_holder hrid
    where("hrid=?","#{hrid}").count 
  end

  def self.available_ratingsfourpointone(lowcf, limit)
    where("cfid >= ? and hrid is null and rating between '4.0' and '4.1'",
         "#{lowcf}").limit(limit) 
  end

  def self.available_ratingsfourpointthree(lowcf, limit)
    where("cfid >= ? and hrid is null and rating between '4.2' and '4.3'",
         "#{lowcf}").limit(limit) 
  end

  def self.available_ratingsfourpointfive(lowcf, limit)
    where("cfid >= ? and hrid is null and rating between '4.4' and '4.5'",
         "#{lowcf}").limit(limit) 
  end

  def self.available_ratingsfourpointseven(lowcf, limit)
    where("cfid >= ? and hrid is null and rating between '4.6' and '4.7'",
         "#{lowcf}").limit(limit) 
  end

  def self.available_lastsummer(lowcf, limit)
    where("cfid >= ? and hrid is null and numjobsls>'0'",
         "#{lowcf}").limit(limit) 
  end
  
  
end