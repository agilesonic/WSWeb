class Convertcalls < ActiveRecord::Base
  self.table_name="convertcalls"
  
  belongs_to :client, :foreign_key => "cfid"

  def self.search_ccrange(key1, key2) 
    where("cfid >= ?", "#{key1}").limit("#{key2}") 
  end
  
  
end