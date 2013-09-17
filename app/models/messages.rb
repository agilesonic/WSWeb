class Messages < ActiveRecord::Base
  self.table_name="messages"
  
  def self.calllog_resolved_message hrid, date
 #   where("followobject = ? and (createts like ? or resolved = ?)", "#{hrid}", '%'.concat(date.to_s).concat('%'), date).uniq
     where("followobject = ? and resolved = ?", "#{hrid}", date).uniq
  end

  def self.calllog_took_message hrid, date
    where("recorder = ? and messdate = ?", "#{hrid}", date.to_s).uniq
  end

  def self.unresolved_messages 
    where("resolved is null ").order('messdate') 
  end
 
  def self.max_id
    maximum("msid")
  end
  
end