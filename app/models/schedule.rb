class Schedule < ActiveRecord::Base
 
  def self.get_schedule
    where("date > '2013-01-01'")     
  end

  def self.get_schedule_date date
    where("date = ?", date)     
  end



  def self.get_schedule_all date1, date2
    where("date between ? and ?", date1, date2)     
  end

  def self.get_schedule_ind id, date1, date2
    where("hrid= ? and date between ? and ?", id, date1, date2)     
  end


end