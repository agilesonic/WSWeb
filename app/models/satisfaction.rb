class Satisfaction < ActiveRecord::Base
  self.table_name="jobsatis"
  
  belongs_to :job, :foreign_key => "jobid"

  def self.max_jobid
    maximum("jobid")
  end

  def self.count_sats jobid
    where("jobid = ? ",jobid).count
  end


  def self.max_satdate
    maximum("satdate")
  end

  def self.calllog hrid, date
    Satisfaction.where("Caller = ? and SatDate = ? ",hrid, date).order("SatDate")
  end

  def self.search_sats(jobid1, jobid2)
    Satisfaction.joins(:job).where("jobs.jobid between ? and ? ",jobid1, jobid2).order("jobs.jobid")
  end

  def self.search_sats_job(jobid1)
    where("jobid= ?",jobid1)
  end




  
end