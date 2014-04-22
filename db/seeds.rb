# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

available_shifts = [
					["Early Shift", "07:30", "13:30"], 
					["Late Shift" , "13:30", "19:30"], 
				    ["Long Day Shift", "07:30", "16:30"],
					["Night Shift", "19:30", "07:30"], 
				   ]
available_shifts.each do |shift|
 name = shift[0]
 start_time = shift[1]
 end_time = shift[2]

 shift = ShiftType.find_by_name(name)
 shift ||= (puts "Adding #{name}"
			ShiftType.create(:name => name,
							 :start_time => start_time,
							 :end_time => end_time )
		   )
end
