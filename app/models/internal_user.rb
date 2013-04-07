class InternalUser < ActiveRecord::Base
	  set_table_name "users"
	
	  def self.search(name, password) 
      where("username = ? and password = ? and status= ?", "#{name}", "#{password}", "enabled") 
    end

end