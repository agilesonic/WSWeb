class Recruit < ActiveRecord::Base
  
  def self.get_recruits
    order('name')
  end

end