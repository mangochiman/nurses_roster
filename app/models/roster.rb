require "composite_primary_keys"

class Roster < ActiveRecord::Base
	set_table_name :roster
    set_primary_keys :nurse_id, :shift_id
    
	belongs_to :nurse
	belongs_to :shift

	def self.randomize_nurses(max_number)
		selected_nurses = []
		available_nurses = Nurse.all.map(&:id)
		selected_nurses += available_nurses.shuffle[1..max_number]
		return selected_nurses
	end

	def self.randomize_available_nurses(nurses_ids, roster_obj, rdate,  required)
		selected_nurses = []
		assigned_ids = []
		roster_date = roster_obj[rdate]
		roster_date.each do |shift, ids|
				assigned_ids << ids
		end
		assigned_ids = assigned_ids.flatten
		free_ids = nurses_ids - assigned_ids
		selected_nurses += free_ids.shuffle[1..required]
		return selected_nurses
	end
end
