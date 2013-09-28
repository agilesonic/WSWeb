class Schedule < ActiveRecord::Base
 
  def self.get_schedule
    where("date > '2013-01-01'")     
  end
end