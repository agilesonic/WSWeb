class Recsupp < ActiveRecord::Base
  
  def self.get_recruiters
    order('company')
  end

end