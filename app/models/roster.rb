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
		consecutive_shifts= []
		night_shifts = Nurse.roster_hash_by_nurse(roster)[nurse_id].to_a

		night_shifts.each do |date, shift|
			unless consecutives.blank?
				consecutive_shifts << shift if consecutive_shifts.last[1] == shift
				#Do Something here when consecutives.count > 3
				#Something like roster[date][nurse_id] = 'Nite Off'
				consecutive_shifts = [] unless consecutive_shifts.last[1] == shift
			end

			consecutive_shifts << shift if consecutives.blank?
		end

		return roster
	end

	def self.validate_monthly_hours(roster)
		required_hours = 38 #This needs to be dynamic
		hours_worked = {}
		hours_worked = Nurse.hours_worked_by_nurse(roster)
		roster_hash = Nurse.roster_hash_by_nurse(roster)


		hours_worked.each do |nurse_id, hours|
			hours_worked = hours["total_hours"]
			if (hours_worked > required_hours)
				nurse_roster = roster_hash[nurse_id].to_a.shuffle
				nurse_roster.each do |rdate, rshift|
					shift_hours = Shift.hours(rshift)
					ids_on_duty = roster[rdate][rshift]
					ids_on_duty = ids_on_duty - [nurse_id]
					roster[rdate][rshift] = ids_on_duty
					hours_worked = hours_worked - shift_hours
					break if hours_worked <= required_hours
				end
			end
		end
		return roster
	end
	
	def self.validate_presence_of_enough_staff_per_shift(roster, rdate, nurses_ids)
		shift_constraints = YAML.load_file("#{Rails.root.to_s}/config/constraints.yml")
		special_case = shift_constraints["Special Case"]
		shift_count = build_total_nurses_per_shift(roster, rdate)
		#{"minimum_level"=>2, "maximum_staff"=>6, "minimum_trained_staff"=>2}
		shift_count.each do |shift, total_nurses|
			minimum_level = shift_constraints[shift]["minimum_level"]
			maximum_staff = shift_constraints[shift]["maximum_staff"]
			minimum_trained_staff = shift_constraints[shift]["minimum_trained_staff"]
			nurse_count = total_nurses
			unless (total_nurses >= minimum_level && total_nurses <= maximum_staff)
				total_shortage_staff = maximum_staff - total_nurses
				nurses = self.randomize_available_nurses(nurses_ids, roster, rdate,  total_shortage_staff)
				nurse_ids = (roster[rdate][shift] + nurses).uniq
				roster[rdate][shift] = nurse_ids
			end
			min_level = nil
			min_trained_staff = nil
			max_level = nil
			unless (special_case[shift]).blank?
				special_case[shift].each do |day, values|
					if (rdate.to_date.strftime("%A").match(day))
						values.each do |rule, value|
							min_level = rule if rule.match(/minimum_level/i)
							min_trained_staff = if rule.match(/minimum_trained_staff/i)
							max_level = rule if rule.match(/maximum_staff/i)
						end

						unless (min_level.blank? && min_trained_staff.blank? && max_level.blank?)
							unless (total_nurses >= min_level && total_nurses <= max_level)
								total_missing_staff = max_level - total_nurses
								ids = self.randomize_available_nurses(nurses_ids, roster, rdate,  total_missing_staff)
								nids = (roster[rdate][shift] + ids).uniq
								roster[rdate][shift] = nids
							end
						end
						min_level = nil
						min_trained_staff = nil
						max_level = nil
					end
				end
        end
      end
      return roster
    end
  end
  
	def self.validate_presence_of_experienced_staff_per_shift(roster, shift_name)

	end

	def self.validate_presence_of_all_shifts
	end

	def self.validate_absence_of_rejected_shift_per_nurse(roster, nurse)

	end

	def self.validate_absence_of_shift_that_should_not_be_consecutive(roster)
		#No night shifts after night shifts
		#No early shift after late shift
	end
	
	def self.validate_combination_of_unprefered_shifts_during_week_ends
	end
	
	def self.validate_one_shift_per_person(roster)
		modified_nurse_ids = []
		roster.each do |rdate, rdata|
			rdata.each do |shift, nurse_ids|
				nurse_ids.each do |nurse_id|
					modified_nurse_ids << nurse_id unless modified_nurse_ids.include?(nurse_id)
				end
				roster[rdate][shift] = modified_nurse_ids
				modified_nurse_ids = []
			end
		end
		return roster
	end

	def self.validate_one_shift_per_person_per_day(roster)
		##Very Important method
	end

	def build_total_nurses_per_shift(roster, rdate)
		shift_count = {}
		roster[rdate].each do |shift, nurse_ids|
			shift_count[shift] = {} if shift_count[shift].blank?
			shift_count[shift] = nurse_ids.count	
		end
		return shift_count
	end
	
	def self.validate_presence_of_day_off_before_night(roster)
		day_off = "Day Off"
		night_shifts = []
	
		roster_hash = Nurse.roster_hash_by_nurse(roster)
		roster_hash.each do |nurse_id, rvalues|
			rvalues = rvalues.sort_by{|date, shift| date.to_date}
			first_roster_date = rvalues.first[0]
			rvalues.each do |rdate, rshift|
				unless night_shifts.blank?
					if rshift.match(/Night/i)					
						night_shifts << rshift					
					else
						night_shifts = []
					end
				end

				night_shifts << rshift if night_shifts.blank? && rshift.match(/Night/i) && first_roster_date != rdate
				unless night_shifts.blank?
					if (night_shifts.count == 1)
						prev_date = (rdate.to_date - 1.day).strftime("%d-%b-%Y").downcase
						day_off_ids = roster[prev_date][day_off] rescue nil
						unless (day_off_ids.blank?)
							roster[prev_date][day_off] = (day_off_ids << [nurse_id])
						else
							roster[prev_date] = {} if roster[prev_date].blank?
							roster[prev_date][day_off] = {} if roster[prev_date][day_off].blank?
							roster[prev_date][day_off] = [nurse_id]
						end
					end					
				end
			end
		end
	   	return roster
	end	
	
	def self.validate_presence_of_day_off_within_seven_days(roster)
		roster_hash = Nurse.roster_hash_by_nurse(roster)
		day_off = "Day Off"
		roster_hash.each do |nurse_id, rvalues|
			shifts_and_dates = rvalues.sort_by{|date, shift| date.to_date}.in_groups_of(7)
			shifts_and_dates.each do |data|
				seven_consecutive_dates_and_shifts = data.flatten.reject{|x|x.blank?}
				unless (seven_consecutive_dates_and_shifts.include?("Day Off"))
					dates = seven_consecutive_dates_and_shifts.select{|d|d unless (d.to_date rescue nil).blank?}
				  	rdate = dates.shuffle.last
					nurses_on_duty = roster[rdate][day_off]
				  	roster[rdate][day_off] = (nurses_on_duty << nurse_id)
				end
			end
		end
		return roster
	end
	
	def self.validate_presence_of_night_within_two_weeks(roster)
		roster_hash = Nurse.roster_hash_by_nurse(roster)
		night_shift = "Night Shift"
		roster_hash.each do |nurse_id, rvalues|
			shifts_and_dates = rvalues.sort_by{|date, shift| date.to_date}.in_groups_of(14)
			shifts_and_dates.each do |data|
				fourteen_consecutive_dates_and_shifts = data.flatten.reject{|x|x.blank?}
				unless (fourteen_consecutive_dates_and_shifts.include?("Night Shift"))
					dates = fourteen_consecutive_dates_and_shifts.select{|d|d unless (d.to_date rescue nil).blank?}
				  	rdate = dates.shuffle.last
					nurses_on_duty = roster[rdate][night_shift]
				  	roster[rdate][late_shift] = (nurses_on_duty << nurse_id)
				end
			end
		end
		return roster
	end
	
	def self.validate_presence_of_maximum_nights_per_month(roster, max_value)
		shift_count_by_nurse = Nurse.roster_hash_shift_count_by_nurse(roster)
		shift_count_by_nurse.each do |nurse_id, svalues|
			svalues.each do |shift, count|
				next unless shift.match(/night/i)
				if (count > max_value)
				   night_shifts_with_dates = Nurse.search_shift(roster, "Night Shift", nurse_id)
				   shift_dates = night_shifts_with_dates.keys.shuffle
				   total_nights = max_value
				   shift_dates.each do |sdate|
						ids_on_duty = roster[sdate][shift]
						roster[sdate][shift] = (ids_on_duty - [nurse_id])
						total_nights -= 1
						break if total_nights <= max_value
				   end
				end
			end
		end
		return roster
	end
	
	def self.validate_presence_of_early_shift_within_three_days(roster)
		early_shift = "Early Shift"
		roster_hash = Nurse.roster_hash_by_nurse(roster)
		roster_hash.each do |nurse_id, rvalues|
			shifts_and_dates = rvalues.sort_by{|date, shift| date.to_date}.in_groups_of(3)
			shifts_and_dates.each do |data|
				three_consecutive_dates_and_shifts = data.flatten.reject{|x|x.blank?}
				unless (three_consecutive_dates_and_shifts.include?("Early Shift"))
				  dates = three_consecutive_dates_and_shifts.select{|d|d unless (d.to_date rescue nil).blank?}
				  rdate = dates.shuffle.last
				  nurses_on_duty = roster[rdate][early_shift]
				  roster[rdate][early_shift] = (nurses_on_duty << nurse_id)
				end
			end
		end
		return roster
	end	
	
	def self.validate_presence_of_late_shift_within_three_days(roster)
		late_shift = "Late Shift"
		roster_hash = Nurse.roster_hash_by_nurse(roster)
		roster_hash.each do |nurse_id, rvalues|
			shifts_and_dates = rvalues.sort_by{|date, shift| date.to_date}.in_groups_of(3)
			shifts_and_dates.each do |data|
				three_consecutive_dates_and_shifts = data.flatten.reject{|x|x.blank?}
				unless (three_consecutive_dates_and_shifts.include?("Late Shift"))
				  dates = three_consecutive_dates_and_shifts.select{|d|d unless (d.to_date rescue nil).blank?}
				  rdate = dates.shuffle.last
				  nurses_on_duty = roster[rdate][late_shift]
				  roster[rdate][late_shift] = (nurses_on_duty << nurse_id)
				end
			end
		end
		return roster
	end

	def self.validate_presence_of_long_day_shift_within_three_days(roster)
		long_day_shift = "Long Day Shift"
		roster_hash = Nurse.roster_hash_by_nurse(roster)
		roster_hash.each do |nurse_id, rvalues|
			shifts_and_dates = rvalues.sort_by{|date, shift| date.to_date}.in_groups_of(3)
			shifts_and_dates.each do |data|
				three_consecutive_dates_and_shifts = data.flatten.reject{|x|x.blank?}
				unless (three_consecutive_dates_and_shifts.include?("Long Day Shift"))
				  dates = three_consecutive_dates_and_shifts.select{|d|d unless (d.to_date rescue nil).blank?}
				  rdate = dates.shuffle.last
				  nurses_on_duty = roster[rdate][long_day_shift]
				  roster[rdate][long_day_shift] = (nurses_on_duty << nurse_id)
				end
			end
		end
		return roster
	end
							
end
