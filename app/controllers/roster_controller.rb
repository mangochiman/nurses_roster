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
		Roster.create_roster(roster, start_date, end_date)
		return roster
	end

	def view_roster
		roster_obj = Roster.all
		@roster = {}
		@roster2 = {}
		roster_obj.each do |roster|
			nurse_name = roster.nurse.first_name.to_s + ' ' + roster.nurse.last_name.to_s
			roster_date = roster.shift.shift_date.to_s
			shift_name = roster.shift.shift_type.name
			@roster[nurse_name] = {} if @roster[nurse_name].blank?
			@roster[nurse_name][roster_date] = {} if @roster[nurse_name][roster_date].blank?
			@roster[nurse_name][roster_date] = shift_name
	
		#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			@roster2[roster_date] = {} if @roster2[roster_date].blank?
			@roster2[roster_date][nurse_name] = {} if @roster2[roster_date][nurse_name]
			@roster2[roster_date][nurse_name] = shift_name
		#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		
		end	
		@x = {"01-jan-14" => {"ernest" =>2 , "john" => 3}, "02-jan-14" => {"john" => 9, "ernest" =>7},
		"03-jan-14" => {"ernest" =>6 , "john" => 4}}
		return @roster2
	end
end
