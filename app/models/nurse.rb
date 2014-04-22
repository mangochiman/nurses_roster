class Nurse < ActiveRecord::Base
	set_table_name :nurse
    set_primary_key :nurse_id
	
	has_many :rosters
end
