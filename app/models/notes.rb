class Notes < ActiveRecord::Base
  self.table_name="notes"
  
  def self.get_job_notes(key) 
    where("objectid=  ?", "#{key}").order("ts") 
  end

end
