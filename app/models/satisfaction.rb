class Satisfaction < ActiveRecord::Base
  self.table_name="jobsatis"
  
  belongs_to :job, :foreign_key => "jobid"

  def self.max_jobid
    maximum("jobid")
  end

  def self.search_sats(jobid1, jobid2)
    Satisfaction.joins(:job).where("jobs.jobid between ? and ? ",jobid1, jobid2).order("jobs.jobid")
  end


  
end