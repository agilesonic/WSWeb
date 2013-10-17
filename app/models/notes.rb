class Notes < ActiveRecord::Base
  self.table_name="notes"
  
  def self.get_job_notes(key) 
    where("objectid=  ?", "#{key}").order("ts") 
  end

  def self.get_num_orignotes(key) 
    where("objectid=  ? and notes like ?", "#{key}", '%Original Job%').count 
  end


  def self.calllog(hrid,today)
    where("recorder = ? and ts like ? ", "#{hrid}", '%'+today.to_s+'%').uniq 
  end

end
