class ShiftRejectionType < ActiveRecord::Base	
	set_table_name :shift_rejection_type
    set_primary_key :shift_rejection_type_id

	has_many :shift_rejections
end
