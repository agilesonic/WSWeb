class Reccontact < ActiveRecord::Base
  
  
  def self.calls_to_recruit key 
    where("recruit= ? ", key) 
  end

end
