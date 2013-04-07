class Messages < ActiveRecord::Base
  self.table_name="messages"
  
   def self.unresolved_messages 
    where("resolved is null ").order('messdate') 
  end

  def self.max_id
    maximum("msid")
  end
  
end