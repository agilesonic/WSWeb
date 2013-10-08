class Job < ActiveRecord::Base
  belongs_to :property, :foreign_key => "jobinfoid"
  
  has_many :jobdnfs, :foreign_key => "jobid", :inverse_of => :job

  has_one :satisfaction, :foreign_key => "jobid"
  
  scope :assigned_jobs, lambda { |schdate, crew| where("schdate = ? and crewname = ?", schdate.mysql_date, crew) } 
  
  WORK_STATUS_CURRENT = "current"
  WORK_STATUS_NEXT    = "next"
  

  def self.max_id
    where("jobid not like ?","JB98%").maximum("JobID")
  end

  def self.jobs_sold_after(date)
    where("datesold>= ?",date)
  end

  def self.calllog hrid, date
    where("SalesID1 = ? and timeSold like ? ",hrid, '%'+"#{date}"+'%') 
  end

  def self.jobs_sold_today date 
    where("datesold = ? and sdate is not null", date) 
  end

  def self.jobs_sold_between(date1, date2,jobid)
    where("datesold between ? and ? and jobid>=?",date1, date2, jobid).order("JobID").limit(20)
  end


  def self.jobs_sold_summer_by(hrid)
    where("sdate between '2013-04-01' and '2013-09-30' and salesid1=? and datesold between ? and ?","#{hrid}", Date.today-5, Date.today).order('datesold DESC')
  end

  def self.jobs_sold_fall_by(hrid)
    where("sdate between '2013-10-01' and '2013-12-31' and salesid1=? and datesold between ? and ?","#{hrid}", Date.today-5, Date.today).order('datesold DESC')
  end



  def self.max_id_prop(jobinfoid)
    where("jobid not like ? and jobinfoid = ?","JB98%","#{jobinfoid}").maximum("JobID")
  end

  def self.number_jobs_schedule(date1, date2) 
    where("sdate between ? and ?", date1, date2).count 
  end

  def self.number_jobs_schedule_curr(date1, date2) 
    where("sdate between ? and ? and datesold = ?", date1, date2, Date.today).count 
  end

  def self.number_jobs_schedule_ytd(date1, date2, date3) 
    where("sdate between ? and ? and datesold <= ?", date1, date2, date3).count 
  end



  def self.dollar_jobs_produced(date1, date2) 
    where("datebi between ? and ?", date1, date2).sum('price') 
  end

  def self.dollar_jobs_produced_curr(date) 
    where("datebi = ?",  date).sum('price')
  end

  def self.dollar_jobs_produced_curr_crew(date, crewname) 
    where("datebi = ? and crewname = ?",  date, "#{crewname}").sum('price')
  end


  def self.number_jobs_incomplete(date1, date2) 
    where("sdate between ? and ? and datebi is null", date1, date2).count
  end




  def self.number_jobs_sold(date1, date2, date3) 
    where("datesold between ? and ? and sdate < ?", date1, date2, date3).count 
  end

  def self.number_jobs_sold_sdates(date1, date2, date3, date4) 
    where("datesold between ? and ? and sdate between ? and ?", date1, date2, date3, date4).count 
  end
  



  def self.number_jobs_sold_ind_curr(id, date) 
    where("salesid1 = ? and datesold = ? and sdate < '2013-09-30'", id, date).count 
  end

  def self.number_jobs_sold_ind_curr_septoct(id, date) 
    where("salesid1 = ? and datesold = ? and sdate between '2013-09-01' and '2013-10-31'", id, date).count 
  end
 
 
  def self.sales_people 
    #where("datesold between ? and ?", date1, date2)
    #find_by_sql("select distinct(salesid1) from jobs where datesold>'2013-04-01'").pluck(:salesid1) 
    where("datesold>'2013-04-01'").uniq.pluck(:salesid1) 
  end

  def self.search_schedule(key, key1) 
    where("sdate between ? and ? and sdate=fdate", key, key1).order("sdate") 
  end

  def self.search_schedule_times(date, time) 
    where("sdate = ? and sdate=fdate and stime like ?", date, "%#{time}%").count('sdate') 
  end


  def self.search_schedule(key, key1) 
    where("sdate between ? and ? and sdate=fdate", key, key1).order("sdate") 
  end

  def self.search_jobs_for_sats(sdate, fdate, limit, lowjobsat) 
    where("datebi between ? and ? and jobid>=?",sdate, fdate, lowjobsat).order("jobid").limit("#{limit}") 
  end
  
  def property
    Property.find(self.JobInfoID)
  end
  


  def client
    Client.find(self.property.CFID)    
  end

  def completed?
    !self.Datebi.nil?
  end
  
  def started?
    !self.reportstime.nil?
  end
  
  def next?
    self.workstatus == WORK_STATUS_NEXT
  end
  
  def current?
    self.workstatus == WORK_STATUS_CURRENT
  end
end
