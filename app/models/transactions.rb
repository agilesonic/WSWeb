class Transactions < ActiveRecord::Base
    belongs_to :job, :foreign_key => "jobid"

  
 # attr_accessible :JobID,:JobInfoID, :JobDesc, :Stime, :SalesID1,
  #      :Sdate, :Fdate
  
  def self.date_paid(key1)
    Transactions.where("transactions.jobid = ? and trantype = ? ",
     "#{key1}", "Payment").maximum("trandate")
      
  end
 
end
