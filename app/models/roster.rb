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

	def self.create_roster(roster_obj, start_date, end_date)
		roster_obj.each do |rdate, shifts_data|
			shift_date = rdate.to_date
			shifts_data.each do |shift_name, nurses_ids|
			    shift_type_id = ShiftType.find_by_name(shift_name).id
				nurses_ids.each do |nurse_id|
					ActiveRecord::Base.transaction do
						shift = Shift.create(:shift_type_id => shift_type_id,
									 :shift_date => shift_date)

						Roster.create(:shift_id => shift.id, 
									  :nurse_id => nurse_id,
									  :start_date => start_date,
									  :end_date => end_date)
					end
				end
			end
		end
	end

	def self.validate_presence_of_night_shift(roster, rdate)
		nurses_ids = Nurse.all.map(&:id)
		required = "3"
		unless roster[rdate].keys.include?('Night Shift')
			roster[rdate]["Night Shift"] = Roster.randomize_available_nurses(nurses_ids, roster_obj, rdate,  required)
		end
		return roster
	end
	
	def self.validate_presence_of_early_shift(roster, rdate)
		nurses_ids = Nurse.all.map(&:id)
		required = "3"
		unless roster[rdate].keys.include?('Early Shift')
			roster[rdate]["Early Shift"] = Roster.randomize_available_nurses(nurses_ids, roster_obj, rdate,  required)
		end
		return roster
	end

	def self.validate_presence_of_late_shift(roster, rdate)
		nurses_ids = Nurse.all.map(&:id)
		required = "3"
		unless roster[rdate].keys.include?('Late Shift')
			roster[rdate]["Late Shift"] = Roster.randomize_available_nurses(nurses_ids, roster_obj, rdate,  required)
		end
		return roster
	end

	def self.validate_presence_of_long_day_shift(roster, rdate)
		nurses_ids = Nurse.all.map(&:id)
		required = "3"
		unless roster[rdate].keys.include?('Long Day Shift')
			roster[rdate]["Long Day Shift"] = Roster.randomize_available_nurses(nurses_ids, roster_obj, rdate,  required)
		end
		return roster
	end

	def self.validate_sequence_of_night_shifts(roster, nurse_id, start_date, end_date)
		nurse_roster = {}
		night_shifts = []
		consecutives = []
		roster.each do |rdate, rvalues|
			roster_date = rdate
			rvalues.each do |shift, nurse_ids|
			 next unless nurse_ids.include?(nurse_id)
				nurse_roster[nurse_id] = {} if nurse_roster[nurse_id].blank?
				nurse_roster[nurse_id][roster_date] = {} if nurse_roster[nurse_id][roster_date].blank?
				nurse_roster[nurse_id][roster_date] = shift
			end		
		end	
		nurse_roster.each do |nid, nvalues|
			nvalues.each do |date, shift|
				night_shifts << [date, shift]
			end
		end
		
		night_shifts.each do |date, shift|
			unless consecutives.blank?
				consecutives << shift if consecutives.last[1] == shift
				#Do Something here when consecutives.count > 3
				#Something like roster[date][nurse_id] = 'Nite Off'
				consecutives = [] unless consecutives.last[1] == shift
			end

			consecutives << shift if consecutives.blank?
		end

		return roster
	end

	def self.validate_weekly_hours
	end
	
	def self.validate_presence_of_enough_staff_per_shift(roster, shift_name)

	end

	def self.validate_presence_of_experienced_staff_per_shift(roster, shift_name)

	end

	def self.validate_presence_of_all_shifts
	end

	def self.validate_absence_of_rejected_shift_per_nurse(roster, nurse)

	end

	def self.validate_absence_of_shift_that_should_not_be_consecutive(roster)

	end
	
	def self.validate_combination_of_unprefered_shifts_during_week_ends
	end
end
