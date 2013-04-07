class OC < ActiveRecord::Base
  self.table_name="oc"
 
  def self.find_partner(key1, key2) 
    OC.where("driver= ? and ocdate= ?", "#{key1}", key2) 
  end

end