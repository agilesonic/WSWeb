class Satisfaction < ActiveRecord::Base
  self.table_name="jobsatis"
  
  belongs_to :job, :foreign_key => "jobid"


#  def self.search_sats(key1)
#    Satisfaction.joins(:job).where("jobs.datebi >= ? ",key1).order("jobs.jobid") 
#  end


  
end