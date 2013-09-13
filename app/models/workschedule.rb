class Workschedule < ActiveRecord::Base
  self.table_name="workschedule"
  #self.rename_column(:workschedule,:type,:type5)

  
#  def self.find_record id
#   where("id=?",id)
#  end


  def self.find_open_sessions
    where("stime is not null and ftime is null and pay='0.00' and profiledate>'2013-09-01'")
  end

  def self.find_closed_sessions
    where("stime is not null and ftime is not null and stime<>ftime and profiledate>=?",Date.today-2).order('rate')
  end


  def self.hours_worked(hrid, date1, date2)
    where("hrid= ? and profiledate between ? and ?", hrid, date1, date2).count
  end

  def self.current_ind(hrid, date1)
    where("hrid= ? and profiledate=?", hrid, date1).order('id')
  end
  
end