class Clientcontact < ActiveRecord::Base
  set_table_name "cfcontact"

  belongs_to :client, :foreign_key => "cfid"

  def self.search_cfcontacts(key1) 
    where("cfid = ? ", "#{key1}").order("dateatt") 
  end



end
