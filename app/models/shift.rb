class Shift < ActiveRecord::Base
	set_table_name :shift
    set_primary_key :shift_id

	has_many :rosters
	belongs_to :shift_type

	def self.hours(shift)
		if (shift.to_i == 0)
			shift = ShiftType.find_by_name(shift)
		else
			shift = ShiftType.find(shift)
		end
		start_time = shift.start_time
		end_time = shift.end_time
		start_time_to_min = (Time.parse(start_time).hour * 60 + Time.parse(start_time).min)
		end_time_to_min = (Time.parse(end_time).hour * 60 + Time.parse(end_time).min)
		total_hours = nil
		if (start_time.to_i >= end_time.to_i)
			total_hours = (start_time_to_min - end_time_to_min)/60
		else
			total_hours = (end_time_to_min - start_time_to_min)/60
		end
		return total_hours
	end
end
