class Messages < ActiveRecord::Base
  self.table_name="messages"
  
  def self.calllog_resolved_message hrid, date
    where("recorder = ? and ts like ? and ts <> createts",hrid,  '%#{date}%')
  end

  def self.calllog_took_message hrid, date
    where("recorder = ? and createts like ?",hrid,  '%#{date}%')
  end

  def self.unresolved_messages 
    where("resolved is null ").order('messdate') 
  end
 
  def self.max_id
    maximum("msid")
  end
  
end