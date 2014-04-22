class RosterController < ApplicationController

	def schedule
		available_shifts = ShiftType.all.map(&:name)
		available_nurses = Nurse.all.map(&:id)
		free_shifts = available_shifts
		start_date = "20/Apr/2014".to_date
		end_date = start_date + 7.days
		roster_dates = (start_date..end_date).to_a
		roster = {}
		required = 3 #Needs to be dynamic
		roster_dates.each do |rdate|
			rdate = rdate.to_s
			roster[rdate] = {}
			while !(free_shifts.blank?)
				random_shift = free_shifts.shuffle.last
				roster[rdate][random_shift] = []
				if (roster[rdate].keys.blank?)
					random_nurses = Roster.randomize_nurses(required) #This needs to receive available nurses
				else
					random_nurses = Roster.randomize_available_nurses(available_nurses, roster, rdate, required)
				end
				roster[rdate][random_shift] += random_nurses
				free_shifts = free_shifts - [random_shift]
			end
			free_shifts = available_shifts
		end
		return roster
	end
end
