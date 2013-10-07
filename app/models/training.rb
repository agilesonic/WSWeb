class Training < ActiveRecord::Base
  
  def self.find_trainings 
    order("tdate") 
  end

end