
class Convertcalls < ActiveRecord::Base
  self.table_name="convertcalls"
  
  belongs_to :client, :foreign_key => "cfid"
  has_many :properties, :foreign_key => "cfid"
  has_many :jobs, :through => :properties

  def self.max_CFID 
    maximum("cfid") 
  end



  def self.search_pendings(hrid, today)
    where("hrid = ? and laststatus=? and lastcall>'2013-04-01' and (followup is null or followup<= ? or lastcall = ?)", "#{hrid}", "Pending", today, today) 
  end

#_______________________________________________________________________________________________________________

  def self.search_profile_ratings(lowcf, limit, hrid, today, r1, r2, numcalls)
    where("cfid >= ? and hrid= ? and (lastjob is null or lastjob<'2013-02-15') and clientstatus='Normal Client' and (laststatus is null or (laststatus <>'Phone OOS' and laststatus <>'Moved')) and"+
    " (followup is null or followup<= ? or (lastcall = ? and summcalls =?) or(lastcall < ? and summcalls =?)) and rating between ? and ?",
         "#{lowcf}","#{hrid}", today, today, "#{numcalls.to_i+1}", today, "#{numcalls}", "#{r1}", "#{r2}").limit(limit) 
  end


  def self.search_profile_lastsummer(lowcf, limit, hrid, today, numcalls)
    where("cfid >= ? and hrid= ? and (lastjob is null or lastjob<'2013-02-15') and clientstatus='Normal Client' and (laststatus is null or (laststatus <>'Phone OOS' and laststatus <>'Moved')) and"+
    " (followup is null or followup<= ? or (lastcall = ? and summcalls =?) or(lastcall < ? and summcalls =?)) and numjobsls>'0'",
    "#{lowcf}","#{hrid}", today, today, "#{numcalls.to_i+1}", today, "#{numcalls}").limit(limit) 
  end
#_______________________________________________________________________________________________________________


      
 
  def self.count_profile_ratings(highcf, hrid, today, r1, r2, numcalls)
    where("cfid >= ? and hrid= ? and (lastjob is null or lastjob<'2013-02-15') and clientstatus='Normal Client' and (laststatus is null or (laststatus <>'Phone OOS' and laststatus <>'Moved')) and (followup is null or followup<= ? or (lastcall = ? and summcalls =?) or(lastcall < ? and summcalls =?)) and rating between ? and ?",
         "#{highcf}","#{hrid}", today, today, "#{numcalls.to_i+1}", today, "#{numcalls}", "#{r1}", "#{r2}").count 
  end
   

  def self.count_profile_lastsummer(highcf, hrid, today, numcalls)
    where("cfid >= ? and hrid= ? and (lastjob is null or lastjob<'2013-02-15') and clientstatus='Normal Client' and (laststatus is null or (laststatus <>'Phone OOS' and laststatus <>'Moved')) and (followup is null or followup<= ? or (lastcall = ? and summcalls =?) or(lastcall < ? and summcalls =?)) and numjobsls>'0'",
         "#{highcf}","#{hrid}", today, today, "#{numcalls.to_i+1}", today,"#{numcalls}").count 
  end 


  def self.count_ccrange(highcf, hrid, profile, today, numcalls)
    count=0
    if profile=='New Estimates'  
      count=count_profile_ratings(highcf, hrid, today,'2.5','2.5',numcalls)
    elsif profile=='3.3=>3.6 clients'  
      count=count_profile_ratings(highcf, hrid, today,'3.3','3.6',numcalls)
    elsif profile=='3.7=>3.9 clients'  
      count=count_profile_ratings(highcf, hrid, today,'3.7','3.9',numcalls)
    elsif profile=='4.0=>4.1 clients'  
      count=count_profile_ratings(highcf, hrid, today,'4.0','4.1',numcalls)
    elsif profile=='4.2=>4.3 clients'  
      count=count_profile_ratings(highcf, hrid, today,'4.2','4.3',numcalls)
    elsif profile=='4.4=>4.5 clients'  
      count=count_profile_ratings(highcf, hrid, today,'4.4','4.5',numcalls)
    elsif profile=='4.6=>4.7 clients'  
      count=count_profile_ratings(highcf, hrid, today,'4.6','4.7',numcalls)
    elsif profile=='Used Us Last Summer'  
      count=count_profile_lastsummer(highcf, limit, hrid, today,numcalls)
    end
    return count
  end
#'New Estimates','3.3=>3.6 clients','3.7=>3.9 clients'



#_______________________________________________________________________________________________________________

  def self.search_pendings_prevnext(hrid, today)
    where("hrid = ? and laststatus=? and lastcall>'2013-04-01' and (lastjob is null or lastjob<'2013-02-15') and clientstatus='Normal Client' and (followup is null or followup<= ? or lastcall = ?)",
     "#{hrid}", "Pending", today, today) 
  end


  def self.search_profile_ratings_prevnext(lowcf, limit, hrid, today, r1, r2, numcalls)
    where("cfid >= ? and hrid= ? and (lastjob is null or lastjob<'2013-02-15') and clientstatus='Normal Client' and (laststatus is null or (laststatus <>'Phone OOS' and laststatus <>'Moved'))"+
    " and (followup is null or followup<= ? or (lastcall = ? and summcalls =?) or(lastcall < ? and summcalls =?)) and rating between ? and ? ",
         "#{lowcf}","#{hrid}", today, today, "#{numcalls.to_i+1}", today, "#{numcalls}", "#{r1}", "#{r2}").limit(limit) 
  end


  def self.search_profile_lastsummer_prevnext(lowcf, limit, hrid, today,numcalls)
    where("cfid >= ? and hrid= ? and (followup is null or followup<= ? or (lastcall = ? and summcalls =?) or(lastcall < ? and summcalls =?)) and (lastjob is null or lastjob<'2013-02-15') and clientstatus='Normal Client' and (laststatus is null or (laststatus <>'Phone OOS' and laststatus <>'Moved')) and numjobsls>'0'",
         "#{lowcf}","#{hrid}", today, today, "#{numcalls.to_i+1}", today, "#{numcalls}").limit(limit) 
  end
#_______________________________________________________________________________________________________________


  def self.search_ccrange_prevnext(lowcf, limit, hrid, profile, today, numcalls)
    list=[]
    pendings=search_pendings(hrid, today)
    profiles=[]
    if profile=='New Estimates'  
      profiles=search_profile_ratings_prevnext(lowcf, limit, hrid, today, '2.5', '2.5', numcalls)
    elsif profile=='3.3=>3.6 clients'  
      profiles=search_profile_ratings_prevnext(lowcf, limit, hrid, today,'3.3', '3.6', numcalls)
    elsif profile=='3.7=>3.9 clients'  
      profiles=search_profile_ratings_prevnext(lowcf, limit, hrid, today,'3.7', '3.9', numcalls)
    elsif profile=='4.0=>4.1 clients'  
      profiles=search_profile_ratings_prevnext(lowcf, limit, hrid, today,'4.0', '4.1', numcalls)
    elsif profile=='4.2=>4.3 clients'  
      profiles=search_profile_ratings_prevnext(lowcf, limit, hrid, today,'4.2', '4.3', numcalls)
    elsif profile=='4.4=>4.5 clients'  
      profiles=search_profile_ratings_prevnext(lowcf, limit, hrid, today,'4.4', '4.5', numcalls)
    elsif profile=='4.6=>4.7 clients'  
      profiles=search_profile_ratings_prevnext(lowcf, limit, hrid, today,'4.6', '4.7', numcalls)
    elsif profile=='Used Us Last Summer'  
      profiles=search_profile_lastsummer_prevnext(lowcf, highcf, hrid, today, numcalls)
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
    return profiles


  end





#============================================================================================================================

  def self.search_ccrange(lowcf, limit, hrid, profile, today,numcalls)
    list=[]
    pendings=search_pendings(hrid, today)
    profiles=[]
    if profile=='New Estimates'  
      profiles=search_profile_ratings(lowcf, limit, hrid, today, '2.5', '2.5',numcalls)
    elsif profile=='3.3=>3.6 clients'  
      profiles=search_profile_ratings(lowcf, limit, hrid, today,'3.3', '3.6',numcalls)
    elsif profile=='3.7=>3.9 clients'  
      profiles=search_profile_ratings(lowcf, limit, hrid, today,'3.7', '3.9',numcalls)
    elsif profile=='4.0=>4.1 clients'  
      profiles=search_profile_ratings(lowcf, limit, hrid, today,'4.0', '4.1',numcalls)
    elsif profile=='4.2=>4.3 clients'  
      profiles=search_profile_ratings(lowcf, limit, hrid, today,'4.2', '4.3',numcalls)
    elsif profile=='4.4=>4.5 clients'  
      profiles=search_profile_ratings(lowcf, limit, hrid, today,'4.4', '4.5',numcalls)
    elsif profile=='4.6=>4.7 clients'  
      profiles=search_profile_ratings(lowcf, limit, hrid, today,'4.6', '4.7',numcalls)
    elsif profile=='Used Us Last Summer'  
      profiles=search_profile_lastsummer(lowcf, limit, hrid, today,numcalls)
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
    return profiles    
  end

  def self.search_unassigned_all
    where("hrid is null and (lastjob is null or lastjob<'2013-02-15')").count 
  end

  def self.search_unassigned(r1,r2)
    where("hrid is null and (lastjob is null or lastjob<'2013-02-15') and rating between ? and ?","#{r1}","#{r2}").count 
  end

  def self.search_unassigned_newestimates 
    where("hrid is null and (lastjob is null or lastjob<'2013-02-15') and cfid>='CF00039366' and rating = '2.5'").count 
  end

  def self.search_unassigned_lastsummer
    where("hrid is null and (lastjob is null or lastjob<'2013-02-15') and numjobsls>'0'").count 
  end



  def self.search_assigned_by_holder_all hrid
    where("hrid=?","#{hrid}").count 
  end

  def self.search_assigned_by_holder(hrid, r1, r2)
    where("hrid=? and rating between ? and ?","#{hrid}","#{r1}", "#{r2}").count 
  end


  def self.search_assigned_by_holder_lastsummer hrid
    where("hrid=? and numjobsls>'0'","#{hrid}").count 
  end

#'New Estimates','3.3=>3.6 clients','3.7=>3.9 clients'
  def self.available_new_estimates(lowcf, limit)
    where("cfid >= ? and hrid is null and (lastjob is null or lastjob<'2013-02-15') and rating= '2.5'",
         "#{lowcf}").limit(limit) 
  end

  def self.available_ratings(lowcf, limit, r1, r2)
    where("cfid >= ? and hrid is null and (lastjob is null or lastjob<'2013-02-15') and rating between ? and ?",
         "#{lowcf}","#{r1}","#{r2}").limit(limit) 
  end


  def self.available_lastsummer(lowcf, limit)
    where("cfid >= ? and hrid is null and (lastjob is null or lastjob<'2013-02-15') and numjobsls>'0'",
         "#{lowcf}").limit(limit) 
  end

  def self.sales_by_assist(datesold1, datesold2, salesid)
  #  Convertcalls.joins(:properties).joins(:jobs).where("jobs.Sdate between '2013-04-01' and '2013-09-30' and jobs.Datesold between ? and ? and convertcalls.hrid= ? and convertcalls.summcalls>'0'",
   #  datesold1, datesold2, "#{salesid}").count
#   Convertcalls.find_by_sql("select * from convertcalls cc, cfjobinfo cj, jobs j where cc.cfid=cj.cfid and cj.jobinfoid=j.jobinfoid and j.sdate between '2013-04-01' and '2013-09-30' and j.datesold between "+datesold1.to_s+" and "+datesold2.to_s+" and cc.hrid= "+"#{salesid}"+" and cc.summcalls>'0'",
#   datesold1, datesold2, "#{salesid}").count
  Convertcalls.find_by_sql("select * from convertcalls cc, cfjobinfo cj, jobs j where cc.cfid=cj.cfid and cj.jobinfoid=j.jobinfoid and j.sdate between '2013-04-01' and '2013-09-30' and j.datesold between '"+datesold1.to_s+"' and '"+datesold2.to_s+"' and cc.hrid= '"+"#{salesid}"+"' and cc.summcalls>'0'").count
    end
  
  def self.sales_by_direct(datesold1, datesold2, salesid)
  #  Convertcalls.joins(:properties).joins(:jobs).where("jobs.Sdate between '2013-04-01' and '2013-09-30' and jobs.Datesold between ? and ? and convertcalls.hrid= ? and convertcalls.summcalls>'0'",
   #  datesold1, datesold2, "#{salesid}").count
#   Convertcalls.find_by_sql("select * from convertcalls cc, cfjobinfo cj, jobs j where cc.cfid=cj.cfid and cj.jobinfoid=j.jobinfoid and j.sdate between '2013-04-01' and '2013-09-30' and j.datesold between "+datesold1.to_s+" and "+datesold2.to_s+" and cc.hrid= "+"#{salesid}"+" and cc.summcalls>'0'",
#   datesold1, datesold2, "#{salesid}").count
  Convertcalls.find_by_sql("select * from convertcalls cc, cfjobinfo cj, jobs j where cc.cfid=cj.cfid and cj.jobinfoid=j.jobinfoid and j.sdate between '2013-04-01' and '2013-09-30' and j.datesold between '"+datesold1.to_s+"' and '"+datesold2.to_s+"' and cc.hrid=j.salesid1 and j.salesid1= '"+"#{salesid}"+"'").count
    end

  def self.max_datesold
    maximum(lastjob).pluck(lastjob) 
  end

  def self.find_by_cfid cfid
    where("cfid= ?","#{cfid}") 
  end
  
end