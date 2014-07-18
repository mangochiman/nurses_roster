class Nurse < ActiveRecord::Base
	set_table_name :nurse
    set_primary_key :nurse_id
	
	has_many :rosters
	has_many :shift_rejections

	def self.roster_hash_by_nurse(roster)
	#the roster is like {"25-jan-2014"=>{"Night Shift"=>[1]}, "22-jan-2014"=>{"Night Shift"=>[1, 2]}, "21-jan-2014"=>{"Night Shift"=>[1, 2]}, "26-jan-2014"=>{"Night Shift"=>[1]}, "23-jan-2014"=>{"Night Shift"=>[1]}, "24-jan-2014"=>{"Night Shift"=>[1]}} to
	#y = {1 => {"21-jan-2014" => "Night Shift", "22-jan-2014" => "Night Shift", "21-jan-2014" => "Day Shift"}}
		roster_hash = {}
		roster.each do |rdate, rvalues|
			rvalues.each do |shift, nurse_ids|
				nurse_ids.flatten.each do |nurse_id|
					roster_hash[nurse_id] = {} if roster_hash[nurse_id].blank?
					roster_hash[nurse_id][rdate] = {} if roster_hash[nurse_id][rdate].blank?
					roster_hash[nurse_id][rdate] = shift
				end
			end
		 end
		return roster_hash
	end

	def self.hours_worked_by_nurse(roster)
		#To return something like {1=>{"total_hours"=>72}, 2=>{"total_hours"=>24}}
		hours_worked = {}
		roster.each do |rdate, rvalues|
			roster_date = rdate
			rvalues.each do |shift, nurse_ids|
				shift_hours = Shift.hours(shift)
				nurse_ids.each do |nurse_id|
					hours_worked[nurse_id] = {} if hours_worked[nurse_id].blank?
					hours_worked[nurse_id]["total_hours"] = 0 if hours_worked[nurse_id]["total_hours"].blank?
					hours_worked[nurse_id]["total_hours"] += shift_hours
				end
			end
		end
		return hours_worked
	end
	
	def self.roster_hash_shift_count_by_nurse(roster)
		#something like 1 => {"Night Shift =>10", "Long Day Shift" => 3, "Late Shift" => 2}
		roster_hash_by_nurse = self.roster_hash_by_nurse(roster)
		shift_count = {}
		roster_hash_by_nurse.each do |nurse_id, rvalues|
			shift_count[nurse_id] = {} if shift_count[nurse_id].blank?
			rvalues.each do |rdate, rshift|
				shift_count[nurse_id][rshift] = {} if shift_count[nurse_id][rshift].blank?
				shift_count[nurse_id][rshift] = 0 if shift_count[nurse_id][rshift].blank?
				shift_count[nurse_id][rshift] += 1
			end
		end

	    return shift_count
	end

	def self.search_shift(roster, shift, nurse_id)
		required_shifts = {}
		nurse_roster = self.roster_hash_by_nurse(roster)[nurse_id]
		nurse_roster.each do |rdate, rshift|
			next unless rshift.upcase.match(shift.upcase)
			required_shifts[rdate] = {}
			required_shifts[rdate] = rshift
		end
		return required_shifts
	end

	def self.roster_hash_rejection_by_nurse(roster, rejection_type)	
		roster_rejection_by_nurse = {}	
		rejection_type_id = ShiftRejectionType.find_by_rejection_type(rejection_type).id
		nurse_shift_rejection_ids = ShiftRejection.find(:all, :conditions => ["shift_rejection_type_id =?", 			rejection_type_id]).map(&:nurse_id).uniq

		nurse_shift_rejection_ids.each do |nurse_id|
			rejected_nurse_shifts = ShiftRejection.find(:all, :conditions => ["shift_rejection_type_id =? AND nurse_id =?", rejection_type_id, nurse_id])
			roster_rejection_by_nurse[nurse_id] = {} if roster_rejection_by_nurse[nurse_id].blank?
			rejected_nurse_shifts.each do |rshift|
				day = rshift.date_or_day
				roster_rejection_by_nurse[nurse_id][day] = [] if roster_rejection_by_nurse[nurse_id][day].blank?
				shift = ShiftType.find(rshift.shift_type_id).name
				roster_rejection_by_nurse[nurse_id][day] << shift
			end
		end

		return roster_rejection_by_nurse
	end

  def self.names(id)
    nurse = Nurse.find(id)
    fname = nurse.first_name
    lname = nurse.last_name
    return fname + ' ' + lname
  end
  
end
