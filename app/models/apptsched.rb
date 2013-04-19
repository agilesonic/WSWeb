class Apptsched < ActiveRecord::Base
  self.table_name="apptsched"

  def self.search_limits(date, stime) 
    where("date = ? and stime = ?", date, "#{stime}")
  end


end