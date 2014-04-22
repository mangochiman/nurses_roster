class ShiftType < ActiveRecord::Base
	set_table_name :shift_type
    set_primary_key :shift_type_id

	has_many :shifts
end
