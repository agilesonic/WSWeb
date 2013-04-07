class Employee < ActiveRecord::Base
  self.table_name= "hr"
  
  
  def self.name_from_id(key) 
    where("hrid= ? ", "#{key}") 
  end

  def self.find_by_hrid(key) 
    Employee.where("hrid= ? ", "#{key}") 
  end
  
  def self.find_by_name(key) 
    Employee.where("name= ? ", "#{key}") 
  end

end
  