class Jobdnf < ActiveRecord::Base
  self.table_name="jobdnf"

  belongs_to :job, :foreign_key => "jobid"


  def self.max_id
    maximum("DNFID")
  end
  
  def self.calllog hrid, date
    where("register = ? and Dnfdate = ? ",hrid, date)
  end



  def self.search_incomplete_dnfs(jobid) 
    where("jobid=? and datebi is null", "#{jobid}").order("sdate") 
  end


  def self.search_completed_dnfs(jobid) 
    where("jobid=? and datebi is not null", "#{jobid}").order("sdate") 
  end


end