class NursesController < ApplicationController

	def list
		@nurses = Nurse.all
	end

	def new
	end

	def create
		first_name = params[:first_name]
        last_name = params[:last_name]
		gender = params[:gender]
        grade = params[:grade]
        if (Nurse.create(:first_name =>first_name, 
						 :last_name =>last_name,
						 :gender => gender, 
						 :grade => grade ))
			redirect_to :action => "list"
		end
	end

	def update_details
		nurse_id = params[:nurse_id]
		@nurse = Nurse.find(nurse_id)
	end

	def create_updated_details
		first_name = params[:first_name]
        last_name = params[:last_name]
		gender = params[:gender]
        grade = params[:grade]
		nurse_id = params[:nurse_id]
		nurse = Nurse.find(nurse_id)
		nurse.first_name = first_name
		nurse.last_name = last_name
		nurse.gender = gender
		nurse.grade = grade
		 if (nurse.save)
			redirect_to :action => "list"
		 end
	end

end
