class RosterController < ApplicationController

	def schedule
		available_shifts = ShiftType.all.map(&:name)
		available_nurses = Nurse.all.map(&:id)
		free_shifts = available_shifts
		start_date = "20/Apr/2014".to_date
		end_date = start_date + 7.days
		roster_dates = (start_date..end_date).to_a
		roster = {}
    shift_constraints = YAML.load_file("#{Rails.root.to_s}/config/constraints.yml")
    
		roster_dates.each do |rdate|
			rdate = rdate.to_s
			roster[rdate] = {}
			while !(free_shifts.blank?)
				random_shift = free_shifts.shuffle.last
        required = 3#shift_constraints[random_shift]["maximum_staff"]
				roster[rdate][random_shift] = []
        random_nurses = Roster.randomize_nurses(required) if (roster[rdate].keys.blank?)
        random_nurses = Roster.randomize_available_nurses(available_nurses, roster, rdate, required) unless (roster[rdate].keys.blank?)
				roster[rdate][random_shift] += random_nurses
				free_shifts = free_shifts - [random_shift]
			end
			free_shifts = available_shifts
      roster = Roster.validate_presence_of_all_shifts(roster, rdate)
      roster = Roster.validate_presence_of_enough_staff_per_shift(roster, rdate, available_nurses)
      roster = Roster.validate_presence_of_trained_staff_per_shift(roster, rdate)
		end

    available_nurses.each do |nurse_id|
      roster = Roster.validate_sequence_of_night_shifts(roster, nurse_id)
      roster = Roster.validate_absence_of_shift_that_should_not_be_consecutive(roster, nurse_id, start_date, end_date)
    end
    
    roster = Roster.validate_monthly_hours(roster)
    #roster = Roster.validate_absence_of_rejected_shift_per_nurse(roster)
    roster = Roster.validate_presence_of_day_off_before_night(roster)
    roster = Roster.validate_presence_of_day_off_within_seven_days(roster)
    roster = Roster.validate_presence_of_night_within_two_weeks(roster)
    roster = Roster.validate_presence_of_maximum_nights_per_month(roster, 3)
    roster = Roster.validate_presence_of_early_shift_within_three_days(roster)
    roster = Roster.validate_presence_of_late_shift_within_three_days(roster)
    roster = Roster.validate_presence_of_long_day_shift_within_three_days(roster)
    roster = Roster.validate_one_shift_per_person(roster)
    #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    raise roster.inspect
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

  def home
    
  end
end
