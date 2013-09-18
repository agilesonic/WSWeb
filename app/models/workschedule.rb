class Workschedule < ActiveRecord::Base
  self.table_name="workschedule"
  #self.rename_column(:workschedule,:type,:type5)

  
#  def self.find_record id
#   where("id=?",id)
#  end


  def self.find_open_sessions
    where("stime is not null and ftime is null and pay='0.00' and profiledate>'2013-09-01'")
  end

  def self.find_closed_sessions_zero
    where("pay='0.00' and profiledate>=?",Date.today-2).order('profiledate').reverse_order
  end

  def self.find_closed_sessions_notzero
    where("stime is not null and ftime is not null and stime<>ftime and pay<>'0.00' and profiledate>=?",Date.today-2).order('profiledate').reverse_order
  end


  def self.find_closed_sessions
    a=find_closed_sessions_zero 
    b=find_closed_sessions_notzero
    c=a+b 
  end



  def self.find_sessions sdate, fdate, hrid
    where("profiledate between ? and ? and hrid=?",
    sdate, fdate, hrid).order('profiledate').reverse_order
  end


  def self.hours_worked(hrid, date1, date2)
    where("hrid= ? and profiledate between ? and ?", hrid, date1, date2).count
  end

  def self.current_ind(hrid, date1)
    where("hrid= ? and profiledate=?", hrid, date1).order('id')
  end

  def self.current_ind_all(date1)
    where("profiledate=?", date1).order('id')
  end
  
  def self.current_open_sessions(hrid, date1)
    where("hrid= ? and profiledate=? and stime is not null and ftime is null", hrid, date1).count
  end

  
end