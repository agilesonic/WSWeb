class Workschedule < ActiveRecord::Base
  
  def self.hours_worked(hrid, date1, date2)
    where("hrid= ? and profiledate between ? and ?", hrid, date1, date2).count
  end

  
end