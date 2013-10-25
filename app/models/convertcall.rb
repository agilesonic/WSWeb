
class Convertcall < ActiveRecord::Base
  #self.table_name="convertcalls"
  
  belongs_to :client
  has_many :properties, :foreign_key => "cfid"
  has_many :jobs, :through => :properties

  def self.max_CFID 
    maximum("cfid") 
  end

  def self.find_by_cfid cfid
    where("cfid=?", "#{cfid}") 
  end


  def self.search__calls (hrid, r1, r2, date,calls)
    if r1=='2.5'
      where("cfid>='CF00041394' and lastjob is null and fallcalls= ? and hrid = ? and rating between ? and ?", "#{calls}", "#{hrid}", "#{r1}", "#{r2}").count
    else
      where("fallcalls= ? and hrid = ? and (lastjob is null or lastjob<'2013-08-31') and rating between ? and ?", "#{calls}", "#{hrid}", "#{r1}", "#{r2}").count
    end 
  end

  def self.search_newests_zero_calls(hrid, today)
    where("cfid>='CF00041394' and lastjob is null and fallcalls='0' and hrid = ?", "#{hrid}") 
  end


  def self.search_pendings(hrid, today)
    where("hrid = ? and laststatus=? and lastcall>'2013-09-01' and (lastjob is null or lastjob<'2013-08-31')"+
    " and (followup is null or followup<= ? or lastcall = ?)"+
    " and clientstatus='Normal Client' and (laststatus is null or "+
    " (laststatus <>'Pending' and laststatus <>'Phone OOS' and laststatus <>'Moved'))", "#{hrid}", "Pending", today, today) 
  end



      
 
  def self.count_profile_ratings(highcf, hrid, today, r1, r2, numcalls)
    where("cfid >= ? and hrid= ? and (lastjob is null or lastjob<'2013-08-31') and clientstatus='Normal Client' and (laststatus is null or (laststatus <>'Phone OOS' and laststatus <>'Moved')) and ((followup is null or followup<= ?) and ((lastcall = ? and fallcalls =?) or((lastcall is null or lastcall < ?) and fallcalls =?))) and rating between ? and ?",
         "#{highcf}","#{hrid}", today, today, "#{numcalls.to_i+1}", today, "#{numcalls}", "#{r1}", "#{r2}").count 
  end
   

  def self.count_profile_lastsummer(highcf, hrid, today, numcalls)
    where("cfid >= ? and hrid= ? and (lastjob is null or lastjob<'2013-08-31') and clientstatus='Normal Client' and (laststatus is null or (laststatus <>'Phone OOS' and laststatus <>'Moved')) and ((followup is null or followup<= ?) and ((lastcall = ? and fallcalls =?) or((lastcall is null or lastcall < ?) and fallcalls =?))) and numjobsls>'0'",
         "#{highcf}","#{hrid}", today, today, "#{numcalls.to_i+1}", today,"#{numcalls}").count 
  end 

      #count=count_profile_lastseptoct(highcf, hrid, today,numcalls)

  def self.count_profile_lastseptoct(highcf, hrid, today, numcalls)
    where("cfid >= ? and hrid= ? and (lastjob is null or lastjob<'2013-08-31') and clientstatus='Normal Client' and"+
    " (laststatus is null or (laststatus <>'Phone OOS' and laststatus <>'Moved')) and "+
    "((followup is null or followup<= ?) and ((lastcall = ? and fallcalls =?) or((lastcall is null or lastcall < ?)"+
    " and fallcalls =?))) and numjobsls>'0'",
         "#{highcf}","#{hrid}", today, today, "#{numcalls.to_i+1}", today,"#{numcalls}").count 
  end 

  def self.count_profile_lastnovdec(highcf, hrid, today, numcalls)
    where("cfid >= ? and hrid= ? and (lastjob is null or lastjob<'2013-08-31') and clientstatus='Normal Client' and"+
    " (laststatus is null or (laststatus <>'Phone OOS' and laststatus <>'Moved')) and "+
    "((followup is null or followup<= ?) and ((lastcall = ? and fallcalls =?) or((lastcall is null or lastcall < ?)"+
    " and fallcalls =?))) and numjobslf>'0'",
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
      count=count_profile_lastsummer(highcf, hrid, today,numcalls)
    elsif profile=='Used Us Last Sept/Oct'  
      count=count_profile_lastseptoct(highcf, hrid, today,numcalls)
    elsif profile=='Used Us Last Nov/Dec'  
      count=count_profile_lastnovdec(highcf, hrid, today,numcalls)
    end
    
    
#          @count=Convertcalls.count_ccrange cc.cfid, hrid, sf.profile, Date.today, sf.numcalls

    return count
  end
#'New Estimates','3.3=>3.6 clients','3.7=>3.9 clients'



#_______________________________________________________________________________________________________________

  def self.search_pendings_prevnext(hrid, today)
    where("hrid = ? and laststatus=? and lastcall>'2013-08-15' and (lastjob is null or lastjob<'2013-08-31') and clientstatus='Normal Client' and (followup is null or followup<= ? or lastcall = ?)",
     "#{hrid}", "Pending", today, today) 
  end


  def self.search_profile_ratings_prevnext(lowcf, limit, hrid, today, r1, r2, numcalls)
    where("cfid >= ? and hrid= ? and (lastjob is null or lastjob<'2013-08-31') and clientstatus='Normal Client' and"+
    " (laststatus is null or (laststatus <>'Pending' and laststatus <>'Phone OOS' and laststatus <>'Moved'))"+
    " and ((followup is null or followup<= ?) and ((lastcall = ? and fallcalls =?) or((lastcall is null or lastcall < ?)"+
    " and fallcalls =?))) and rating between ? and ? ",
         "#{lowcf}","#{hrid}", today, today, "#{numcalls.to_i+1}", today, "#{numcalls}", "#{r1}", "#{r2}").limit(limit) 
  end


  def self.search_profile_lastsummer_prevnext(lowcf, limit, hrid, today,numcalls)
    where("cfid >= ? and hrid= ? and ((followup is null or followup<= ?) and ((lastcall = ? and fallcalls =?)"+
    " or((lastcall is null or lastcall < ?) and fallcalls =?))) and (lastjob is null or lastjob<'2013-08-31')"+
    " and clientstatus='Normal Client' and (laststatus is null or (laststatus <>'Phone OOS' and laststatus <>'Moved'))"+
    " and numjobsls>'0'", "#{lowcf}","#{hrid}", today, today, "#{numcalls.to_i+1}", today, "#{numcalls}").limit(limit) 
  end

  def self.search_profile_lastseptoct_prevnext(lowcf, limit, hrid, today,numcalls)
    where("cfid >= ? and hrid= ? and ((followup is null or followup<= ?) and ((lastcall = ? and fallcalls =?)"+
    " or((lastcall is null or lastcall < ?) and fallcalls =?))) and (lastjob is null or lastjob<'2013-08-31')"+
    " and clientstatus='Normal Client' and (laststatus is null or (laststatus <>'Phone OOS' and laststatus <>'Moved'))"+
    " and numjobsls>'0'", "#{lowcf}","#{hrid}", today, today, "#{numcalls.to_i+1}", today, "#{numcalls}").limit(limit) 
  end

 #  where("cfid >= ? and hrid= ? and (lastjob is null or lastjob<'2013-08-31') and clientstatus='Normal Client' and"+
 #   " (laststatus is null or (laststatus <>'Phone OOS' and laststatus <>'Moved')) and"+
 #   " ((followup is null or followup<= ?) and (lastcall = ? and fallcalls =?) or((lastcall is null or lastcall < ?)"+
 #   " and fallcalls =?)) and numjobsls>'0'",
 #   "#{lowcf}","#{hrid}", today, today, "#{numcalls.to_i+1}", today, "#{numcalls}").limit(limit) 
 



  def self.search_profile_lastnovdec_prevnext(lowcf, limit, hrid, today,numcalls)
    where("cfid >= ? and hrid= ? and ((followup is null or followup<= ?) and ((lastcall = ? and fallcalls =?)"+
    " or((lastcall is null or lastcall < ?) and fallcalls =?))) and (lastjob is null or lastjob<'2013-08-31')"+
    " and clientstatus='Normal Client' and (laststatus is null or (laststatus <>'Phone OOS' and laststatus <>'Moved'))"+
    " and numjobslf>'0'", "#{lowcf}","#{hrid}", today, today, "#{numcalls.to_i+1}", today, "#{numcalls}").limit(limit) 
  end
#_______________________________________________________________________________________________________________


  def self.search_ccrange_prevnext(lowcf, limit, hrid, profile, today, numcalls)
    list=[]
   # newests=search_newests_zero_calls(hrid, today)
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
    elsif profile=='Used Us Last Sept/Oct'  
      profiles=search_profile_lastseptoct_prevnext(lowcf, highcf, hrid, today, numcalls)
    elsif profile=='Used Us Last Nov/Dec'  
      profiles=search_profile_lastnovdec_prevnext(lowcf, highcf, hrid, today, numcalls)
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



#_______________________________________________________________________________________________________________

  def self.search_profile_ratings(lowcf, limit, hrid, today, r1, r2, numcalls)
    where("cfid >= ? and hrid= ? and (lastjob is null or lastjob<'2013-08-31') and clientstatus='Normal Client' and (laststatus is null or (laststatus <>'Pending' and laststatus <>'Phone OOS' and laststatus <>'Moved')) and"+
    " ((followup is null or followup<= ?) and ((lastcall = ? and fallcalls =?) or((lastcall is null or lastcall < ?) and fallcalls =?))) and rating between ? and ?",
         "#{lowcf}","#{hrid}", today, today, "#{numcalls.to_i+1}", today, "#{numcalls}", "#{r1}", "#{r2}").order('cfid').limit(limit) 
  end

#......
#  def self.search_profile_ratings_prevnext(lowcf, limit, hrid, today, r1, r2, numcalls)
#    where("cfid >= ? and hrid= ? and (lastjob is null or lastjob<'2013-08-31') and clientstatus='Normal Client' and (laststatus is null or (laststatus <>'Phone OOS' and laststatus <>'Moved'))"+
#    " and ((followup is null or followup<= ?) and ((lastcall = ? and fallcalls =?) or((lastcall is null or lastcall < ?) and fallcalls =?))) and rating between ? and ? ",
#         "#{lowcf}","#{hrid}", today, today, "#{numcalls.to_i+1}", today, "#{numcalls}", "#{r1}", "#{r2}").limit(limit) 
#  end
#..........



  def self.search_profile_lastsummer(lowcf, limit, hrid, today, numcalls)
    where("cfid >= ? and hrid= ? and (lastjob is null or lastjob<'2013-08-31') and clientstatus='Normal Client' and (laststatus is null or (laststatus <>'Phone OOS' and laststatus <>'Moved')) and"+
    " ((followup is null or followup<= ?) and (lastcall = ? and fallcalls =?) or((lastcall is null or lastcall < ?) and fallcalls =?)) and numjobsls>'0'",
    "#{lowcf}","#{hrid}", today, today, "#{numcalls.to_i+1}", today, "#{numcalls}").limit(limit) 
  end

  def self.search_profile_lastseptoct(lowcf, limit, hrid, today, numcalls)
    where("cfid >= ? and hrid= ? and (lastjob is null or lastjob<'2013-08-31') and clientstatus='Normal Client' and"+
    " (laststatus is null or (laststatus <>'Phone OOS' and laststatus <>'Moved')) and"+
    " ((followup is null or followup<= ?) and (lastcall = ? and fallcalls =?) or((lastcall is null or lastcall < ?)"+
    " and fallcalls =?)) and numjobsls>'0'",
    "#{lowcf}","#{hrid}", today, today, "#{numcalls.to_i+1}", today, "#{numcalls}").limit(limit) 
  end

  def self.search_profile_lastnovdec(lowcf, limit, hrid, today, numcalls)
    where("cfid >= ? and hrid= ? and (lastjob is null or lastjob<'2013-08-31') and clientstatus='Normal Client' and"+
    " (laststatus is null or (laststatus <>'Phone OOS' and laststatus <>'Moved')) and"+
    " ((followup is null or followup<= ?) and (lastcall = ? and fallcalls =?) or((lastcall is null or lastcall < ?)"+
    " and fallcalls =?)) and numjobslf>'0'",
    "#{lowcf}","#{hrid}", today, today, "#{numcalls.to_i+1}", today, "#{numcalls}").limit(limit) 
  end
#_______________________________________________________________________________________________________________






  def self.search_ccrange(lowcf, limit, hrid, profile, today,numcalls)
    list=[]
    newests=search_newests_zero_calls(hrid, today)
    pendings=search_pendings(hrid, today)
    profiles=[]
    if profile=='New Estimates'  
      if numcalls=='0'
        numcalls='1'
      end
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
    elsif profile=='Used Us Last Sept/Oct'  
      profiles=search_profile_lastseptoct(lowcf, limit, hrid, today,numcalls)
    elsif profile=='Used Us Last Nov/Dec'  
      profiles=search_profile_lastnovdec(lowcf, limit, hrid, today,numcalls)
    end
    #if pendings.nil? && profiles.nil?
    #  return listov
    #elsif pendings.nil? && !profiles.nil?
    #  return profiles
    #elsif !pendings.nil? && profiles.nil?
    #  return pendings
    #elsif !pendings.nil? && !profiles.nil?
    #  return pendings+profiles
    #else
    #  return list
    #end
    #return profiles
    list=newests+pendings
    list=list+profiles
    return list    
  end

  def self.search_unassigned_all
    where("hrid is null and (lastjob is null or lastjob<'2013-08-31') and (rating>='3.3' or"+ 
    " (cfid>='CF00041394' and rating = '2.5'))").count 
  end

  def self.search_unassigned(r1,r2)
    where("hrid is null and (lastjob is null or lastjob<'2013-08-31') and rating between ? and ?","#{r1}","#{r2}").count 
  end

  def self.search_unassigned_newestimates 
    where("hrid is null and (lastjob is null or lastjob<'2013-08-31') and cfid>='CF00041394' and rating = '2.5'").count 
  end

  def self.search_unassigned_lastsummer
    where("hrid is null and (lastjob is null or lastjob<'2013-08-31') and numjobsls>'0'").count 
  end



  def self.search_assigned_by_holder_all hrid
    if hrid.nil?
      where("hrid is null and (lastjob is null or lastjob<'2013-08-31')").count 
    else
      where("hrid=? and (lastjob is null or lastjob<'2013-08-31')","#{hrid}").count 
    end
  end

  def self.search_assigned_by_holder(hrid, r1, r2)
    if hrid.nil?
      where("hrid is null and rating between ? and ? and (lastjob is null or lastjob<'2013-08-31')","#{r1}", "#{r2}").count 
    else
      where("hrid=? and rating between ? and ? and (lastjob is null or lastjob<'2013-08-31')","#{hrid}","#{r1}", "#{r2}").count 
    end
  end


  def self.search_assigned_by_holder_lastsummer hrid
    if hrid.nil?
      where("hrid is null and numjobsls>'0' and (lastjob is null or lastjob<'2013-08-31')").count
    else
      where("hrid=? and numjobsls>'0' and (lastjob is null or lastjob<'2013-08-31')","#{hrid}").count
    end 
  end

  def self.search_assigned_by_holder_newestimates hrid
    if hrid.nil?
      where("hrid is null and cfid>='CF00041394' and (lastjob is null or lastjob<'2013-08-31')").count
    else
      where("hrid=? and cfid>='CF00041394' and (lastjob is null or lastjob<'2013-08-31')","#{hrid}").count
    end 
  end


  def self.search_assigned_by_holder_cc(hrid, r1, r2)
    if hrid.nil?
      where("hrid is null and rating between ? and ? and (lastjob is null or lastjob<'2013-08-31')","#{r1}", "#{r2}")
    else
      where("hrid=? and rating between ? and ? and (lastjob is null or lastjob<'2013-08-31')","#{hrid}","#{r1}", "#{r2}")
    end 
  end


  def self.search_assigned_by_holder_lastsummer_cc hrid
    if hrid.nil?
      where("hrid is null and numjobsls>'0' and (lastjob is null or lastjob<'2013-08-31')")
    else
      where("hrid=? and numjobsls>'0' and (lastjob is null or lastjob<'2013-08-31')","#{hrid}")
    end
  end

  def self.search_assigned_by_holder_newestimates_cc hrid
#    where("hrid=? and cfid>='CF00039366'","#{hrid}") 
    if hrid.nil?
      where("hrid is null and cfid>='CF00041394' and rating='2.5' and (lastjob is null or lastjob<'2013-08-31')")
    else
      where("hrid=? and cfid>='CF00041394' and rating='2.5' and (lastjob is null or lastjob<'2013-08-31')","#{hrid}")
    end 
  end


#'New Estimates','3.3=>3.6 clients','3.7=>3.9 clients'
  def self.available_new_estimates(lowcf, limit)
    where("cfid >= ? and hrid is null and (lastjob is null or lastjob<'2013-08-31') and rating= '2.5'",
         "#{lowcf}").limit(limit) 
  end

  def self.available_ratings(lowcf, limit, r1, r2)
    where("cfid >= ? and hrid is null and (lastjob is null or lastjob<'2013-08-31') and rating between ? and ?",
         "#{lowcf}","#{r1}","#{r2}").limit(limit) 
  end


  def self.available_lastsummer(lowcf, limit)
    where("cfid >= ? and hrid is null and (lastjob is null or lastjob<'2013-08-31') and numjobsls>'0'",
         "#{lowcf}").limit(limit) 
  end

  def self.sales_by_assist(datesold1, datesold2, salesid)
  #  Convertcalls.joins(:properties).joins(:jobs).where("jobs.Sdate between '2013-04-01' and '2013-09-30' and jobs.Datesold between ? and ? and convertcalls.hrid= ? and convertcalls.fallcalls>'0'",
   #  datesold1, datesold2, "#{salesid}").count
#   Convertcalls.find_by_sql("select * from convertcalls cc, cfjobinfo cj, jobs j where cc.cfid=cj.cfid and cj.jobinfoid=j.jobinfoid and j.sdate between '2013-04-01' and '2013-09-30' and j.datesold between "+datesold1.to_s+" and "+datesold2.to_s+" and cc.hrid= "+"#{salesid}"+" and cc.fallcalls>'0'",
#   datesold1, datesold2, "#{salesid}").count
  Convertcalls.find_by_sql("select * from convertcalls cc, cfjobinfo cj, jobs j where cc.cfid=cj.cfid and cj.jobinfoid=j.jobinfoid and j.sdate between '2013-04-01' and '2013-09-30' and j.datesold between '"+datesold1.to_s+"' and '"+datesold2.to_s+"' and cc.hrid= '"+"#{salesid}"+"' and cc.fallcalls>'0'").count
    end
  
  def self.sales_by_direct(datesold1, datesold2, salesid)
  #  Convertcalls.joins(:properties).joins(:jobs).where("jobs.Sdate between '2013-04-01' and '2013-09-30' and jobs.Datesold between ? and ? and convertcalls.hrid= ? and convertcalls.fallcalls>'0'",
   #  datesold1, datesold2, "#{salesid}").count
#   Convertcalls.find_by_sql("select * from convertcalls cc, cfjobinfo cj, jobs j where cc.cfid=cj.cfid and cj.jobinfoid=j.jobinfoid and j.sdate between '2013-04-01' and '2013-09-30' and j.datesold between "+datesold1.to_s+" and "+datesold2.to_s+" and cc.hrid= "+"#{salesid}"+" and cc.fallcalls>'0'",
#   datesold1, datesold2, "#{salesid}").count
  Convertcalls.find_by_sql("select * from convertcalls cc, cfjobinfo cj, jobs j where cc.cfid=cj.cfid and cj.jobinfoid=j.jobinfoid and j.sdate between '2013-04-01' and '2013-09-30' and j.datesold between '"+datesold1.to_s+"' and '"+datesold2.to_s+"' and cc.hrid=j.salesid1 and j.salesid1= '"+"#{salesid}"+"'").count
    end


  def self.sales_by_assist_sdates(datesold1, datesold2, salesid, sdate1, sdate2)
    Convertcalls.find_by_sql("select * from convertcalls cc, cfjobinfo cj, jobs j where cc.cfid=cj.cfid and cj.jobinfoid=j.jobinfoid and j.sdate between '2013-04-01' and '2013-09-30' and j.datesold between '"+datesold1.to_s+"' and '"+datesold2.to_s+"' and cc.hrid= '"+"#{salesid}"+"' and cc.fallcalls>'0' and sdate between '"+sdate1.to_s+"' and '"+sdate2.to_s+"'").count
  end
  
  def self.sales_by_direct_sdates(datesold1, datesold2, salesid, sdate1, sdate2)
    Convertcalls.find_by_sql("select * from convertcalls cc, cfjobinfo cj, jobs j where cc.cfid=cj.cfid and cj.jobinfoid=j.jobinfoid and j.sdate between '2013-04-01' and '2013-09-30' and j.datesold between '"+datesold1.to_s+"' and '"+datesold2.to_s+"' and cc.hrid=j.salesid1 and j.salesid1= '"+"#{salesid}"+"' and sdate between '"+sdate1.to_s+"' and '"+sdate2.to_s+"'").count
  end

  def self.max_datesold
    maximum("lastjob")
  end

  def self.find_by_cfid cfid
    where("cfid= ?","#{cfid}") 
  end
  
  def self.search__highcf hrid, r1, r2, today
    where("hrid= ? and rating between ? and ? and lastcall= ?","#{hrid}","#{r1}","#{r2}",today).order('cfid') 
  end
  
  def self.search__highcf_lastsummer hrid, today
    where("hrid= ? and numjobsls>'0' and lastcall= ?","#{hrid}",today).order('cfid') 
  end

  def self.search__highcf_lastseptoct hrid, today
    where("hrid= ? and numjobsls>'0' and lastcall= ?","#{hrid}",today).order('cfid') 
  end

  def self.search__highcf_lastnovdec hrid, today
    where("hrid= ? and numjobslf>'0' and lastcall= ?","#{hrid}",today).order('cfid') 
  end


end