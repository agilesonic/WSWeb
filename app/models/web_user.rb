class WebUser < ActiveRecord::Base
  set_table_name "webusers"
  belongs_to :client, :foreign_key => "cfid"
end