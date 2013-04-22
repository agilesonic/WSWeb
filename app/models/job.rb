class Job < ActiveRecord::Base
  belongs_to :property, :foreign_key => "jobinfoid"
  
  has_many :jobdnfs, :foreign_key => "jobid", :inverse_of => :job

  has_one :satisfaction, :foreign_key => "jobid"
  
  scope :assigned_jobs, lambda { |schdate, crew| where("schdate = ? and crewname = ?", schdate.mysql_date, crew) } 
  
  WORK_STATUS_CURRENT = "current"
  WORK_STATUS_NEXT    = "next"
  

  def self.max_id
    where("jobs.jobid not like ?","JB98%").maximum("JobID")
  end

  def self.number_jobs_sold(date1, date2, date3) 
    where("datesold between ? and ? and sdate < ?", date1, date2, date3).count 
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

  def self.search_jobs_for_sats(key) 
    where("datebi >= ?", key).order("jobid") 
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
