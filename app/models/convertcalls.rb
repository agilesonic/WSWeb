
class Convertcalls < ActiveRecord::Base
  self.table_name="convertcalls"
  
  belongs_to :client, :foreign_key => "cfid"
  has_many :properties, :foreign_key => "cfid"
  has_many :jobs, :through => :properties

  def self.max_CFID 
    maximum("cfid") 
  end



  def self.search_pendings(hrid, today)
    where("hrid = ? and laststatus=? and (followup is null or followup<= ?)", "#{hrid}", "Pending", today) 
  end

  def self.search_profile_nocalls(lowcf, limit, hrid, today)
    where("cfid >= ? and hrid= ? and summcalls= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending')",
         "#{lowcf}","#{hrid}", "0", today).limit(limit) 
  end

  def self.search_profile_ratingsnewestimates(lowcf, limit, hrid, today)
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending') and rating = '2.5'",
         "#{lowcf}","#{hrid}", today).limit(limit) 
  end

  def self.search_profile_ratingsthreepointsix(lowcf, limit, hrid, today)
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending') and rating between '3.3' and '3.6'",
         "#{lowcf}","#{hrid}", today).limit(limit) 
  end

  def self.search_profile_ratingsthreepointnine(lowcf, limit, hrid, today)
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending') and rating between '3.7' and '3.9'",
         "#{lowcf}","#{hrid}", today).limit(limit) 
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

  def self.count_profile_ratingsnewestimates(highcf, hrid, today)
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending')  and rating = '2.5'",
         "#{highcf}","#{hrid}", today).count 
  end
   
  def self.count_profile_ratingsthreepointsix(highcf, hrid, today)
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending')  and rating between '3.3' and '3.6'",
         "#{highcf}","#{hrid}", today).count 
  end 

  def self.count_profile_ratingsthreepointnine(highcf, hrid, today)
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ?) and (laststatus is null or laststatus<>'Pending')  and rating between '3.7' and '3.9'",
         "#{highcf}","#{hrid}", today).count 
  end 


#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
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
#'New Estimates','3.3=>3.6 clients','3.7=>3.9 clients'

  def self.search_ccrange(lowcf, limit, hrid, profile, today)
    list=[]
    pendings=search_pendings(hrid, today)
    profiles=[]
    if profile=='No Calls'
      profiles=search_profile_nocalls(lowcf, limit, hrid, today)
    elsif profile=='New Estimates'  
      profiles=search_profile_ratingsnewestimates(lowcf, limit, hrid, today)
    elsif profile=='3.3=>3.6 clients'  
      profiles=search_profile_ratingsthreepointsix(lowcf, limit, hrid, today)
    elsif profile=='3.7=>3.9 clients'  
      profiles=search_profile_ratingsthreepointnine(lowcf, limit, hrid, today)
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

  def self.search_unassigned_fourseven
    where("hrid is null and rating between '4.6' and '4.7'").count 
  end

  def self.search_unassigned_fourfive
    where("hrid is null and rating between '4.4' and '4.5'").count 
  end

  def self.search_unassigned_fourthree
    where("hrid is null and rating between '4.2' and '4.3'").count 
  end

  def self.search_unassigned_fourone
    where("hrid is null and rating between '4.0' and '4.1'").count 
  end

  def self.search_unassigned_threenine 
    where("hrid is null and rating between '3.7' and '3.9'").count 
  end

  def self.search_unassigned_threesix 
    where("hrid is null and rating between '3.3' and '3.6'").count 
  end

  def self.search_unassigned_newestimates 
    where("hrid is null and cfid>='CF00039366' and rating = '2.5'").count 
  end

  def self.search_unassigned_lastsummer
    where("hrid is null and numjobsls>'0'").count 
  end



  def self.search_assigned_by_holder hrid
    where("hrid=?","#{hrid}").count 
  end

  def self.search_assigned_by_holder_fourseven hrid
    where("hrid=? and rating between '4.6' and '4.7'","#{hrid}").count 
  end

  def self.search_assigned_by_holder_fourfive hrid
    where("hrid=? and rating between '4.4' and '4.5'","#{hrid}").count 
  end

  def self.search_assigned_by_holder_fourthree hrid
    where("hrid=? and rating between '4.2' and '4.3'","#{hrid}").count 
  end

  def self.search_assigned_by_holder_fourone hrid
    where("hrid=? and rating between '4.0' and '4.1'","#{hrid}").count 
  end

  def self.search_assigned_by_holder_threenine hrid
    where("hrid=? and rating between '3.7' and '3.9'","#{hrid}").count 
  end

  def self.search_assigned_by_holder_threesix hrid
    where("hrid=? and rating between '3.3' and '3.6'","#{hrid}").count 
  end

  def self.search_assigned_by_holder_newestimates hrid
    where("hrid=? and rating = '2.5'","#{hrid}").count 
  end


  def self.search_assigned_by_holder_lastsummer hrid
    where("hrid=? and numjobsls>'0'","#{hrid}").count 
  end

#'New Estimates','3.3=>3.6 clients','3.7=>3.9 clients'
  def self.available_new_estimates(lowcf, limit)
    where("cfid >= ? and hrid is null and rating= '2.5'",
         "#{lowcf}").limit(limit) 
  end

  def self.available_ratingsthreepointsix(lowcf, limit)
    where("cfid >= ? and hrid is null and rating between '3.3' and '3.6'",
         "#{lowcf}").limit(limit) 
  end

  def self.available_ratingsthreepointnine(lowcf, limit)
    where("cfid >= ? and hrid is null and rating between '3.7' and '3.9'",
         "#{lowcf}").limit(limit) 
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

  def self.sales_by_assist(datesold1, datesold2, salesid)
    Convertcalls.joins(:properties).joins(:jobs).where("jobs.datesold between ? and ? and jobs.salesid1= ? and summcalls>'0'",
     datesold1, datesold2, "#{salesid}").count
  end

  
  
end