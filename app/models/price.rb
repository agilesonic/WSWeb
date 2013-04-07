class Price < ActiveRecord::Base
    set_table_name "cfjobprice"

    belongs_to :property, :foreign_key => "jobinfoid", :inverse_of => :prices

end