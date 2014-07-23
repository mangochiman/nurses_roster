require 'csv'
class RosterController < ApplicationController

  def create_roster
    start_date = params[:start_date]
    end_date = params[:end_date]

    available_shifts = ShiftType.all.map(&:name)
		available_nurses = Nurse.all.map(&:id)
		free_shifts = available_shifts
		start_date = start_date.to_date
		end_date = end_date.to_date
		roster_dates = (start_date..end_date).to_a
		roster = {}
    shift_constraints = YAML.load_file("#{Rails.root.to_s}/config/constraints.yml")

		roster_dates.each do |rdate|
			rdate = rdate.to_s
			roster[rdate] = {}
			while !(free_shifts.blank?)
				random_shift = free_shifts.shuffle.last
        if (shift_constraints[random_shift])
            required = shift_constraints[random_shift]["maximum_staff"] unless shift_constraints[random_shift]["maximum_staff"].blank?
            required = rand(10) if shift_constraints[random_shift]["maximum_staff"].blank?
        else
          required = rand(10)
        end
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
		Roster.create_roster(roster, start_date, end_date)
    render :text => true and return
  end
  
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

  def content
    @roster_menu =  [
                      ["Create Roster", 'create_01.png'],
                      ["Edit Roster", "check_list.png"],
                      ["Swap Shifts", "swap_01.png"],
                      ["Delete Roster", "delete_01.png"],
                      ["View Roster", "view_Details.png"]
                    ]

    @nurses_menu =  [
                      ["New Nurse", 'nurse_02.png'],
                      ["Edit Nurse", "edit_01.png"],
                      ["Import from CSV", "upload.png"],
                      ["Delete Nurse", "delete_01.png"],
                      ["View Nurses", "view_01.png"]
                    ]

    @users_menu =  [
                      ["New User", 'add_user.png'],
                      ["Edit User", "edit_user.png"],
                      ["Delete User", "delete_user.png"],
                      ["Block User", "blocked_girl.png"],
                      ["View Users", "view_01.png"]
                    ]
                    
    @settings_menu =  [
                      ["Adjust Shift Settings", "adjust_02.png"],
                      ["Set Routine Shift Rejections", "settings_02.png"],
                      ["Set Special Shift Rejections", "settings_01.png"],
                      ["Extra Settings", 'extra_settings_02.png']
                    ]

    @extra_settings_menu =  [
                      ["Edit Username", "edit_username.png"],
                      ["Edit Password", 'password_01.png']
                    ]
  end

  def process_csv_file
    csv_text = File.read(params[:file].path)
    csv = CSV.parse(csv_text, :headers => true)
    header = csv[0]
    csv.each do |row|
      next if row == header
      row = row.to_s.split(/,/)
      employee_number = row[0] #There is need to add this field in nurse table
      first_name = row[1]
      last_name = row[2]
      gender = row[3]
      grade = row[4]
      Nurse.create(
          :first_name => first_name,
          :last_name => last_name,
          :gender => gender,
          :grade => grade
      )
    end
    redirect_to :action => 'content'
  end

  def view_main_roster
		roster_obj = Roster.all
		roster_hash = {}
		roster_obj.each do |roster|
			nurse_id = roster.nurse_id
			roster_date = roster.shift.shift_date.strftime("%d-%b-%Y")
			shift_name = roster.shift.shift_type.name
			roster_hash[nurse_id] = {} if roster_hash[nurse_id].blank?
			roster_hash[nurse_id][roster_date] = {} if roster_hash[nurse_id][roster_date].blank?
			roster_hash[nurse_id][roster_date] = shift_name
		end
    render :json => roster_hash and return
  end

  def return_roster_dates
    roster_dates = Roster.all.collect{|roster|roster.shift.shift_date.strftime("%d-%b-%Y")}.uniq.sort
    render :json => roster_dates and return
  end

  def roster_summary_by_date
    rdate = params[:rdate].to_date
    roster = {}
    shifts = Shift.find(:all, :conditions => ["DATE(shift_date) =?", rdate])
    shifts.each do |shift|
      shift_name = shift.shift_type.name
      roster[shift_name] = {} if roster[shift_name].blank?
      roster[shift_name]["count"] = 0 if roster[shift_name]["count"].blank?
      roster[shift_name]["count"] += 1
    end
    render :json => roster and return
  end

  def roster_summary_by_nurse
    nurse_id = params[:nurse_id]
    start_date = params[:start_date].to_date rescue nil #To be used later
    end_date = params[:end_date].to_date rescue nil #To be used later
    nurse_roster = Roster.find(:all, :conditions => ["nurse_id =?", nurse_id])
    roster = {}
    nurse_names = Nurse.names(nurse_id)
    roster["names"] = nurse_names
    nurse_roster.each do |r|
      shift_name = r.shift.shift_type.name
      roster[shift_name] = {} if roster[shift_name].blank?
      roster[shift_name]["count"] = 0 if roster[shift_name]["count"].blank?
      roster[shift_name]["count"] += 1
    end
    render :json => roster and return
  end

  def roster_summary_by_shift
    shift_name = params[:shift_name]
    rdate = params[:rdate].to_date
    shift_type_id = ShiftType.find_by_name(shift_name).id
    roster_data = Roster.find(:all, :joins => [:shift], :conditions => ["shift_type_id =? AND
        DATE(shift_date) =?", shift_type_id, rdate])
    names = {}
    roster_data.each do |roster|
      nurse_id = roster.nurse_id
      nurse_names = Nurse.names(nurse_id)
      names[nurse_id] = {}
      names[nurse_id] = nurse_names
    end
    total_nurses = names.keys.length
    names["total_nurses"] = total_nurses
    render :json => names and return
  end
  
end
