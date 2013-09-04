class Transactions < ActiveRecord::Base
    belongs_to :job, :foreign_key => "jobid"

  
  def self.calllog hrid, date
    where("PersonID = ? and trandate like ? ",hrid, "%#{date}%")
  end

  
  def self.date_paid(key1)
    Transactions.where("transactions.jobid = ? and trantype = ? ",
     "#{key1}", "Payment").maximum("trandate")
      
  end
 
end
