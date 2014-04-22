class Shift < ActiveRecord::Base
	set_table_name :shift
    set_primary_key :shift_id

	has_many :rosters
	belongs_to :shift_type
end
