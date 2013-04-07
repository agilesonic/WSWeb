class Job < ActiveRecord::Base
  belongs_to :property, :foreign_key => "jobinfoid"
  
  has_many :jobdnfs, :foreign_key => "jobid", :inverse_of => :job

#  has_one :satisfaction, :foreign_key => "jobid"
  
  scope :assigned_jobs, lambda { |schdate, crew| where("schdate = ? and crewname = ?", schdate.mysql_date, crew) } 
  
  WORK_STATUS_CURRENT = "current"
  WORK_STATUS_NEXT    = "next"
  

  def self.max_id
    where("jobs.jobid not like ?","JB98%").maximum("JobID")
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
