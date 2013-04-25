class Clientrate < ActiveRecord::Base
  self.table_name="clientrate"

  def self.find_rating(cfid) 
    where("cfid = ?","#{cfid}").order("cfid") 
  end

  
end