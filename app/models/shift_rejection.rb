class ShiftRejection < ActiveRecord::Base
	set_table_name :shift_rejection
    set_primary_key :shift_rejection_id

	belongs_to :nurse
end
