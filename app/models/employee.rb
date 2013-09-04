class Employee < ActiveRecord::Base
  self.table_name= "hr"
  
  
  def self.just_id_from_name(key) 
    where("name= ? ", "#{key}").pluck('HRID') 
  end

  def self.just_name_from_id(key) 
    where("hrid= ? ", "#{key}").pluck('name') 
  end

  def self.name_from_id(key) 
    where("hrid= ? ", "#{key}") 
  end

  def self.find_by_hrid(key) 
    Employee.where("hrid= ? ", "#{key}") 
  end
  
  def self.find_by_name(key) 
    Employee.where("name= ? ", "#{key}") 
  end

  def self.active_sales_people 
    where("jobdesc like '%Sales Agent%' and status='active'").order('name')
  end

  def self.active_sales_people_only 
    where("jobdesc like '%Sales Agent%' and status='active'").order('name').pluck('name')
  end


end
  